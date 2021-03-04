module Rapidfire
  class Survey < ActiveRecord::Base
    has_many  :attempts
    has_many  :questions
    has_many :attempts

    validates :name, :presence => true

    # has_rich_text :description
  end
end
