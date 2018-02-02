# frozen_string_literal: true

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :trackable, :validatable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              type: String, default: ''
  field :encrypted_password, type: String, default: ''

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  field :role, type: Symbol

  has_and_belongs_to_many :events, class_name: 'EDM::Event', inverse_of: nil

  def self.role_enum
    %i(admin events)
  end
  delegate :role_enum, to: :class

  validates :password_confirmation, presence: true, if: :encrypted_password_changed?
  validates :role, presence: true, inclusion: { in: User.role_enum }

  rails_admin do
    object_label_method { :email }

    list do
      field :email
      field :role
      field :current_sign_in_at
      field :current_sign_in_ip
    end

    edit do
      field :email do
        required true
      end
      field :role, :enum do
        required true
        # It would be nicer to disable the input, but on RailsAdmin enum
        # type fields, html_attributes appears to be ignored
        # html_attributes do
        #   { disabled: true }
        # end
        enum do
          User.role_enum.reject { |role| bindings[:view].current_user == bindings[:object] && bindings[:object].role != role }
        end
      end
      field :password
      field :password_confirmation
      field :events do
        inline_add false
      end
    end
  end
end
