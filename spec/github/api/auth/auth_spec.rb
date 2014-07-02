require 'yaml'
require 'octokit'
require 'github/api/auth'

RSpec.describe Github::Api::Auth do
  describe '.new and #authenticate' do
    context 'having file .github_token in place with valid token' do
      let(:valid_token) { '123456' }
      let(:client) { double('Octokit::Client') }

      it 'successfully authenticates without asking user for anything' do
        allow(File).to receive(:exists?).with('.github_token') { true }
        allow(YAML).to receive(:load_file).
          with('.github_token') { { token: valid_token } }
        allow(Octokit::Client).to receive(:new).
          with(access_token: valid_token) { client }
        expect_any_instance_of(subject).not_to receive(:basic_authentication)
        github = subject.new
        expect(github.github).to eq(client)
      end
    end

    context 'having file .github_token in place with invalid token' do
      let(:invalid_token) { '654321' }

      it 'falls back to basic authentication' do
        allow(File).to receive(:exists?).with('.github_token') { true }
        allow(YAML).to receive(:load_file).
          with('.github_token') { { token: invalid_token } }
        allow(Octokit::Client).to receive(:new).
          with(access_token: invalid_token).and_raise(RuntimeError.new)
        expect_any_instance_of(subject).to receive(:basic_authentication) { true }
        github = subject.new
      end
    end

    context 'without file .github_token, but having ~/.github_token' do
      let(:valid_token) { '123456' }
      let(:client) { double('Octokit::Client') }
      let(:path) { "#{ENV['HOME']}/.github_token" }

      it 'successfully authenticates without asking user for anything' do
        allow(File).to receive(:exists?).with('.github_token') { false }
        allow(File).to receive(:exists?).with(path) { true }
        allow(YAML).to receive(:load_file).
          with(path) { { token: valid_token } }
        allow(Octokit::Client).to receive(:new).
          with(access_token: valid_token) { client }
        expect_any_instance_of(subject).not_to receive(:basic_authentication)
        github = subject.new
        expect(github.github).to eq(client)
      end
    end
  end

  describe '#basic_authentication' do
    let(:username) { 'john' }
    let(:password) { 'super strong password' }
    let(:client) { double('Octokit::Client') }
    let(:token) { '123456' }
    let(:authorization) { { scopes: 'repo:status', note: 'super note' } }
    let(:otp) { '987654' }

    before do
      allow(Octokit::Client).to receive(:new).
        with(login: username, password: password) { client }
    end

    context 'having #configure_from_file failed' do
      before do
        allow_any_instance_of(subject).to receive(:configure_from_file) { false }
        allow_any_instance_of(subject).to receive(:gen_token_note) { 'super note' }
        allow_any_instance_of(subject).to receive(:ask).
          with('github username: ') { username }
        allow_any_instance_of(subject).to receive(:ask).
          with('password: ') { password }
      end

      it 'gets called' do
        expect_any_instance_of(subject).to receive(:basic_authentication) { true }
        github = subject.new
      end

      it 'asks user for username and password and creates access token' do
        expect_any_instance_of(subject).to receive(:ask).
          with('github username: ') { username }
        expect_any_instance_of(subject).to receive(:ask).
          with('password: ') { password }
        expect_any_instance_of(subject).to receive(:create_access_token) do
          { token: token }
        end
        expect_any_instance_of(subject).to receive(:store_token).
          with({ token: token })
        github = subject.new
      end

      describe 'scopes option' do
        it 'allows to set scopes option for access token' do
          allow_any_instance_of(subject).to receive(:gen_token_note) { 'crazy note' }
          expect(client).to receive(:create_authorization).
            with(scopes: ['user', 'repo'], note: 'crazy note') do
            { token: '123456', scopes: ['user', 'repo'] }
          end
          github = subject.new(scopes: ['user', 'repo'])
          expect(github.scopes).to eq(['user', 'repo'])
        end
      end

      context 'having one time password required' do
        it 'asks user for otp' do
          expect(client).to receive(:create_authorization).
            with(authorization).and_raise(Octokit::OneTimePasswordRequired.new)
          expect_any_instance_of(subject).to receive(:ask).
            with('one time password required: ') { otp }
          expect(client).to receive(:create_authorization).
            with(authorization.merge(headers: { 'X-GitHub-OTP' => otp })) do
            { token: token }
          end
          expect_any_instance_of(subject).to receive(:store_token).
            with({ token: token })
          github = subject.new
        end
      end
    end
  end
end

