require 'spec_helper'

describe Gitlab::Ci::Build::Credentials::Registry do
  let(:build) { create(:ci_build, name: 'spinach', stage: 'test', stage_idx: 0) }
  let(:registry_url) { 'registry.example.com:5005' }

  subject { Gitlab::Ci::Build::Credentials::Registry.new(build) }

  before do
    stub_container_registry_config(host_port: registry_url)
  end

  it 'contains valid DockerRegistry credentials' do
    expect(subject).to be_kind_of(Gitlab::Ci::Build::Credentials::Registry)

    expect(subject.username).to eq 'gitlab-ci-token'
    expect(subject.password).to eq build.token
    expect(subject.url).to eq registry_url
    expect(subject.type).to eq 'registry'
  end

  describe '.valid?' do
    subject { Gitlab::Ci::Build::Credentials::Registry.new(build).valid? }

    context 'when registry is enabled' do
      before do
        stub_container_registry_config(enabled: true)
      end

      it { is_expected.to be_truthy }
    end

    context 'when registry is disabled' do
      before do
        stub_container_registry_config(enabled: false)
      end

      it { is_expected.to be_falsey }
    end
  end
end