require 'acts_as_votable/helpers/words'

module ActsAsVotable
  class Vote < ::ActiveRecord::Base

    include Helpers::Words

    self.primary_key = :id

    before_create :set_id
    
    if defined?(ProtectedAttributes) || ::ActiveRecord::VERSION::MAJOR < 4
      attr_accessible :votable_id, :votable_type,
        :voter_id, :voter_type,
        :votable, :voter,
        :vote_flag, :vote_scope
    end

    belongs_to :votable, :polymorphic => true
    belongs_to :voter, :polymorphic => true

    scope :up, lambda{ where(:vote_flag => true) }
    scope :down, lambda{ where(:vote_flag => false) }
    scope :for_type, lambda{ |klass| where(:votable_type => klass) }
    scope :by_type,  lambda{ |klass| where(:voter_type => klass) }

    validates_presence_of :votable_id
    validates_presence_of :voter_id
    
    protected

    def set_id
      return if self.id
      self.id = loop do
        random_id = [*('a'..'z'),*('A'..'Z')].shuffle[0,11].join
        break random_id unless self.class.exists?(id: random_id)
      end
    end
  end

end

