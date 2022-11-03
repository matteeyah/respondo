# frozen_string_literal: true

RSpec.describe ApplicationHelper do
  describe '#auth_provider_link' do
    subject(:auth_provider_link) { helper.auth_provider_link(provider, 'model') { 'test' } }

    (UserAccount.providers.keys + BrandAccount.providers.keys).each do |account_provider|
      context "when provider is #{account_provider}" do
        let(:provider) { account_provider }

        it do
          expect(auth_provider_link).to match(%r{
            <form\ class="button_to"\ method="post"\ action="/auth/.*\?state=model">
            <button\ data-turbo="false"\ type="submit">test</button>
            </form>
            }x)
        end
      end
    end
  end

  describe '#provider_human_name' do
    subject(:provider_human_name) { helper.provider_human_name(provider) }

    (UserAccount.providers.except(:developer).keys + BrandAccount.providers.except(:developer).keys)
      .uniq.each do |account_provider|
        context "when provider is #{account_provider}" do
          let(:provider) { account_provider }

          it 'returns human mame' do
            expect(provider_human_name).to be_an_instance_of(String)
          end
        end
      end
  end

  describe '#safe_blank_link_to' do
    subject(:safe_blank_link_to) { helper.safe_blank_link_to('Link Text', 'https://example.com', class: 'nav-link') }

    it { is_expected.to eq('<a target="_blank" rel="noopener noreferrer" class="nav-link" href="https://example.com">Link Text</a>') }
  end

  describe '#bi_icon' do
    subject(:bi_icon) { helper.bi_icon('test') }

    it { is_expected.to eq('<i class="bi bi-test "></i>') }
  end

  describe '#show_settings_collapse?' do
    subject(:show_settings_collapse?) { helper.show_settings_collapse? }

    let(:user_double) { instance_double(User) }
    let(:brand_double) { instance_double(Brand) }

    before do
      without_partial_double_verification do
        allow(helper).to receive(:current_user).and_return(user_double)
        allow(helper).to receive(:current_brand).and_return(brand_double)
      end
    end

    context 'when current page is user settings' do
      before do
        allow(helper).to receive(:current_page?).with(edit_user_path(user_double)).and_return(true)
      end

      it { is_expected.to be(true) }
    end

    context 'when current page is brand settings' do
      before do
        allow(helper).to receive(:current_page?).with(edit_user_path(user_double)).and_return(false)
        allow(helper).to receive(:current_page?).with(edit_brand_path(brand_double)).and_return(true)
      end

      it { is_expected.to be(true) }
    end

    context 'when current page is something else' do
      before do
        allow(helper).to receive(:current_page?).with(edit_user_path(user_double)).and_return(false)
        allow(helper).to receive(:current_page?).with(edit_brand_path(brand_double)).and_return(false)
      end

      it { is_expected.to be(false) }
    end
  end
end
