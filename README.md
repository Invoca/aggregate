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

Aggregate classes can use all of the built in Rails validations.  The aggregate class is validated and saved when the containing class is saved. 

### Lists
If you need to store a list of attributes, declare the list using **aggregate_has_many**.  For example, the passport has a list of foreign visits.

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
![Diagram from yuml.me](docs/class_diagram.png)
