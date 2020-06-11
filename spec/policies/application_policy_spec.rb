# frozen_string_literal: true

RSpec.describe ApplicationPolicy, type: :policy do
  subject(:application_policy) { described_class }

  permissions :index?, :show?, :create?, :new?, :update?, :edit?, :destroy? do
    it 'denies access to everyone' do
      expect(application_policy).not_to permit(FactoryBot.create(:user))
    end
  end

  describe ApplicationPolicy::Scope do
    let(:scope) { described_class.new(FactoryBot.create(:user), Ticket.all) }

    describe '#resolve' do
      it 'resolves whole relation' do
        expect(scope.resolve).to eq(Ticket.all)
      end
    end
  end
end
