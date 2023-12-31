class Event < ApplicationRecord
  belongs_to :user
  has_many :bookings, dependent: :destroy
  has_many_attached :photos
  validates :name, :description, :price, :category, :location, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  CATEGORIES = %w[Music Education Business Food&Drink Performing&VisualArts]

  include PgSearch::Model
  pg_search_scope :search_by_name_and_category,
  against: [ :name, :category ],
  using: {
    tsearch: { prefix: true }
  }
  geocoded_by :location
  after_validation :geocode, if: :will_save_change_to_location?

  has_one :chatroom, dependent: :destroy
  after_create :create_chatroom

  private

  def create_chatroom
    Chatroom.create(name: "Chatroom for #{Event.name}", event: self)
  end
end
