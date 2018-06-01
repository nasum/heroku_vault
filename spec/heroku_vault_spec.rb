require "spec_helper"

RSpec.describe HerokuVault do
  it "has a version number" do
    expect(HerokuVault::VERSION).not_to be nil
  end
end
