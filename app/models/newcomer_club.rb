class NewcomerClub < ActiveRecord::Base
  # must contain :category & :name
  validates_presence_of :category, :name

  # validate :pdf, :fb, :web, :group value
  validates_format_of :pdf, :with => /.+\.pdf/, :allow_nil => true
  validates_format_of :fb, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix, :allow_nil => true
  validates_format_of :web, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix, :allow_nil => true
  validates_format_of :group, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix, :allow_nil => true

  # validate :category, :color value
  validates_inclusion_of :category, :in => ["curricular", "studentAssociation", "alumnian"]
  validates_inclusion_of :color, :in => ["white", "milk", "grey", "default"], :allow_nil => true

end
