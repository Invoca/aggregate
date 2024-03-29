# Aggregate

This Gem allows a no-sql style document store to be stored on your rails models in sql databases.

## Dependencies
- Ruby ~> 2.6
- ActiveRecord >= 4.2, < 7

### Getting Started

In you Gemfile add:

```
  gem aggregate
```

If you were not already using large_text_fields, there will be a schema migration.  Go ahead and run that.  It is fast.

### Defining Aggregates on Rails Models
To add aggregated attributes to an existing rails model, include **Aggregate::Container** on the model, tell aggregate where to store the data, add the storage field and then define the aggregate attributes you want.   For example, the following adds some attributes to a passport class.

```ruby
class Passport < ActiveRecord::Base
  ...
  include Aggregate::Container
  store_aggregates_using :aggregate_storage

  fields do
    ...
    aggregate_storage :text, limit: MYSQL_LONG_TEXT_UTF8_LIMIT
    ...
  end

  aggregate_attribute :gender,           :enum, limit: [:male, :female], required: true
  aggregate_attribute :city,             :string,   required: true
  aggregate_attribute :state,            :string,   required: true
  aggregate_attribute :birthdate,        :datetime, required: true
  aggregate_attribute :height,           :decimal
  aggregate_attribute :weight,           :float
  aggregate_attribute :other_details,    :hash
  aggregate_attribute :has_id,           :boolean
  aggregate_attribute :steps,            :integer
  aggregate_attribute :photo,            "PassportPhoto"
  aggregate_has_many  :foreign_visits,   "ForeignVisit"
  ...
end
```

#### Warning about ActiveRecord Callbacks Ordering

When `store_aggregates_using` is called it will define a `before_save` callback that is responsible for serializing all aggregate attributes into the storage field (e.g. `aggregate_storage` in the above example). That means that if you want to assign/change values for an aggregate attribute in a callback, it needs to be done in a `before_save` that is defined **before** `stores_aggregates_using` is called.

See [the Rails docs](https://guides.rubyonrails.org/active_record_callbacks.html#available-callbacks) for more info on available callbacks.

Here's a trivial example:

```ruby
class Passport < ActiveRecord::Base
  include Aggregate::Container

  # ...

  before_save :update_birthdate
  store_aggregates_using :aggregate_storage

  # ...

  def update_birthdate
    self.birthdate = Time.now
  end
end
```

### Nesting Aggregate classes
Aggregate attributes can be full ruby classes with their own attributes and validations.  For example, the passport above has a "photo" attribute of type "PassportPhoto".  This is an aggregate class.  To define aggregate class, create a ruby class that derives from Aggregate::Base and defines attributes.  For example here is the definition of passport photo.

```ruby
class PassportPhoto < Aggregate::Base
  attribute :photo_url, :string
  attribute :color,     :boolean
end
```
Note, when defining aggregate attributes on aggregate classes, you can drop the aggregate_ prefix in front of many methods.

Aggregate classes can use all of the built in Rails validations.  The aggregate class is validated and saved when the containing class is saved.

### Lists
If you need to store a list of attributes, declare the list using **aggregate_has_many**.  For example, the passport has a list of foreign visits.

### Referencing other models
If you have an aggregate that needs to refer to another rails model, you can use **aggregate_belongs_to** to declare the association.  For example, if a PassportPhoto needs a reference to a model named "PhotoProvider" you could declare the association as follows.

```ruby
class PassportPhoto < Aggregate::Base
  belongs_to :provided_by, class_name: "PhotoProvider"
end
```
You could then set and navigate the association.

### Treating Missing Attribute Keys as the Default Value
By default, if the stored serialized data representing the attributes is missing an attributes key, the value for that attribute will be `nil`.

This can be problematic when adding a new attribute but you already have stored serialized data somewhere, such as in a database column.

If you would instead like to have attributes that are missing their key in the serialized data return the attribute default value, you can define `aggregate_treat_undefined_attributes_as_default_value?` on your aggregate container as true.

```ruby
class User < ApplicationRecord
  include Aggregate::Container

  def self.aggregate_treat_undefined_attributes_as_default_value?
    true
  end
end
```


### Storing aggregates on large text fields
Aggregates can be stored on large text fields.  To do this, replace the **store_aggregates_using** call with a **store_aggregates_using_large_text_field**.

```
class Passport < ActiveRecord::Base
  ...
  include Aggregate::Container
  store_aggregates_using_large_text_field

  ...
end
```

This style of storage convenient because you can add aggregates to models without running a migration, **but try not to use it**.  Writing to the large text field table causes
additional database writes and the large text field table has bloated to the point where it is a problem for our database.

To migrate a table from using a large text field to attached storage, you can change the code above to the following.

```
class Passport < ActiveRecord::Base
  ...
  # This can be removed when the migration has completed
  include LargeTextField::Owner
  large_text_field :aggregate_store

  include Aggregate::Container
  store_aggregates_using :aggregate_storage, migrate_from_storage_field: :aggregate_store

  fields do
    ...
    aggregate_storage :text, limit: MYSQL_LONG_TEXT_UTF8_LIMIT
    ...
  end
  ...
end
```

This will generate a schema migration.  With the above change the code will read aggregate structure from the attached large text field if the local storage is empty.  Any updates will be written to the local storage.  You will need to migrate every row by loading and saving the model in a well throttled background script.
 When that is done you can remove the large text field declaration, the migrate from argument and drop the rows from the large text field table.

### Schema Migrations
Changes to aggregates generally do not require database schema migrations. However, the following behaviors should be noted.

- If you add a new attribute and you load a model that does not have that attribute it will be at its default value.
- If you load an attribute that has a value of `nil`, it will **not** use the default value of the attribute.  It will instead return `nil`.  We don't want to read from the default value of the attribute because we don't know if the value was saved as `nil` or was a new attribute.  See the usage of `schema_version` below for how to handle this.
- If you load a model and it has an attribute that has been deleted, the extra attributes will be ignored.

You may have some cases where this default behavior isn't good enough.  For those you can add a schema version attribute to your class.  Any time an instance is loaded at a version that is different that the current version it will call a method you defined to migrate the data. For example, this is an updated version of the passport photo class that adds a thumbnail url and sets the thumbnail url to the photo url if an older schema is loaded.

```ruby
class PassportPhoto < Aggregate::Base
  attribute :photo_url, :string
  attribute :color,     :boolean
  attribute :photo_thumbnail_url, :string
  schema_version "1.0", :fixup_schema

  def fixup_schema(loaded_version)
    if loaded_version.to_f < 1.0
      self.photo_thumbnail_url = photo_url
    end
  end
end
```

### Design
By default, when an model includes **Aggregate::Container**, a LargeTextField named **aggregate_store** is added to the model.  Aggregates are marshalled to
and from this store using the **before_validate** and **before_large_text_field_save** callbacks.

The model class is also given a hash **aggregate_container_options** with the options **:use_storage_field** and **:use_large_text_field_as_failover**.
These options are defaulted to **nil** and **false** respectively, and this specifies that the container will simply use the aforementioned **aggregate_store**
foreign key relation to **large_text_fields**.

If **:use_storage_field** is instead set to the name of a field in the model (a **:text** field is recommended), the aggregate data will be loaded and saved
in the specified field/column. When **:use_large_text_field_as_failover** is set to true (and **:use_storage_field** is non-blank), the container will load
the aggregate data from the field specified by **:use_storage_field** but if the data is missing or blank it will then attempt to load the data from the
**aggregate_store** large text field. Once the data is loaded however, it will save it as usual in the field specified by **:use_storage_field**.

Things to note:

* **Aggregate::Store** provides methods for defining a collection of attributes associated with an instance of the class.
* The classes in blue below are a part of the public interface.  The remaining are parts of the implementation.
* **Attribute::Base** defines an interface for saving, restoring and validating an attribute.  All of the classes derived from this provide support attributes of one type.



## Test Setup
The first time you run tests on a system you will need to run the following commands.
```
bundle install
rake db:migrate
```
You can run tests by calling `rake`

![Diagram from yuml.me](docs/class_diagram.png)
