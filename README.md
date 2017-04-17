# Aggregate

This Gem allows a no-sql style document store to be stored on your rails models in sql databases. 

### Getting Started

In you Gemfile add:

```
  gem aggregate
```

If you were not already using large_text_fields, there will be a schema migration.  Go ahead and run that.  It is fast.

### Defining Aggregates on Rails Models
To add aggregated attributes to an existing rails model, include **Aggregate::Container** on the model and then define the aggregate attributes you want.   For example, the following adds some attributes to a passport class.

```ruby
class Passport < ActiveRecord::Base
  ...
  include Aggregate::Container

  aggregate_attribute :gender,           :enum, limit: [:male, :female], required: true
  aggregate_attribute :city,             :string,   required: true
  aggregate_attribute :state,            :string,   required: true
  aggregate_attribute :birthdate,        :datetime, required: true
  aggregate_attribute :height,           :decimal
  aggregate_attribute :weight,           :decimal
  aggregate_attribute :photo,            "PassportPhoto"
  aggregate_has_many  :foreign_visits,   "ForeignVisit"
  ...
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

### Store on model instead of Large Text Field
Sometimes you may want to store the aggregate on a model itself rather than in large_text_fields. This is useful, for example, because you can set its limit yourself.

```
class Passport < ActiveRecord::Base
  ...
  include Aggregate::Container
  self.aggregate_container_options[:use_storage_field] = :aggregate_storage

  fields do
    ...
    aggregate_storage :text, limit: MYSQL_LONG_TEXT_UTF8_LIMIT
    ...
  end

  ...
end
```

### Schema Migrations
Changes to aggregates do not require database schema migrations.  If you add a new attribute and you load a model that does not have that attribute it will be at its default value.  If you load a model and it has an attribute that has been deleted, the extra attributes will be ignored.  

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


![Diagram from yuml.me](docs/class_diagram.png)
