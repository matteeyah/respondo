acme = Organization.find_or_create_by!(screen_name: "ACME Corp")

source = OrganizationAccount.find_or_create_by!(external_uid: "account_123", provider: :twitter) do |org_account|
  org_account.screen_name = "looney_toones"
  org_account.organization = acme
end

buggs_bunny = Author.find_or_create_by!(external_uid: "author_123", provider: :twitter) do |buggs|
  buggs.username = "buggs_bunny"
  buggs.external_link = "https://looney_toones.com/buggs"
  buggs.organization = acme
end

donald_duck = Author.find_or_create_by!(external_uid: "author_234", provider: :twitter) do |donald|
  donald.username = "donald_duck"
  donald.external_link = "https://looney_toones.com/donald"
  donald.organization = acme
end

looney_toones = Author.find_or_create_by!(external_uid: "author_345", provider: :twitter) do |looney|
  looney.username = "looney_toones"
  looney.external_link = "https://looney_toones.com"
  looney.organization = acme
end

buggs_user = User.find_or_create_by!(name: "Buggs Bunny") do |buggs|
  buggs.organization = acme
end

developer = User.find_or_create_by!(name: "Developer") do |developer_user|
  developer_user.organization = acme
end

developer_account = UserAccount.find_or_create_by!(external_uid: "account_123") do |account|
  account.provider = :google_oauth2
  account.email = "matija@respondohub.com"
  account.user = developer
end

root_mention = Mention.find_or_create_by!(external_uid: "uid_123") do |mention|
  mention.external_link = "https://looney_toones.com/123"
  mention.content = "That's all folks!"
  mention.organization = acme
  mention.author = looney_toones
  mention.source = source
end

reply_mention = Mention.find_or_create_by!(external_uid: "uid_234") do |mention|
  mention.external_link = "https://looney_toones.com/234"
  mention.content = "No, there's more!"
  mention.organization = acme
  mention.author = donald_duck
  mention.source = source
  mention.parent = root_mention
end

Mention.find_or_create_by!(external_uid: "uid_345") do |mention|
  mention.external_link = "https://looney_toones.com/345"
  mention.content = "Who's the boss here!?"
  mention.organization = acme
  mention.author = looney_toones
  mention.source = source
  mention.parent = reply_mention
  mention.creator = buggs_user
end

InternalNote.find_or_create_by!(creator: buggs_user) do |note|
  note.content = "Who does this guy think he is?"
  note.mention = reply_mention
end

Mention.find_or_create_by!(external_uid: "uid_456") do |mention|
  mention.external_link = "https://looney_toones.com/456"
  mention.content = "Donald is going quackers!"
  mention.organization = acme
  mention.author = buggs_bunny
  mention.source = source
end
