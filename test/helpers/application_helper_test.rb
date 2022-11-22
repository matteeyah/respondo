# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  (UserAccount.providers.keys + BrandAccount.providers.keys).uniq.each do |account_provider|
    test "#auth_provider_link returns auth link when provider is #{account_provider}" do
      expected_auth_link = %r{
      <form\ class="button_to"\ method="post"\ action="/auth/.*">
      <button\ data-turbo="false"\ type="submit">test</button>
      </form>
      }x

      assert_match expected_auth_link, auth_provider_link(account_provider) { 'test' }
    end

    test "#provider_human_name returns human name when provider is #{account_provider}" do
      assert_instance_of String, provider_human_name(account_provider)
    end
  end

  test '#safe_blank_link_to returns a safe blank link' do
    expected_blank_link =
      '<a target="_blank" rel="noopener noreferrer" class="nav-link" href="https://example.com">Link Text</a>'

    assert_equal expected_blank_link, safe_blank_link_to('Link Text', 'https://example.com', class: 'nav-link')
  end

  test '#bi_icon returns i element with correct classes' do
    assert_equal '<i class="bi bi-test "></i>', bi_icon('test')
  end
end
