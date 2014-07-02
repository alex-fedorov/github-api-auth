require 'yaml'
require 'octokit'
require 'highline/import'

class Github::Api::Auth::Klass; include Github::Api::Auth end

module Github::Api::Auth
  AUTH_FILE = "#{ENV['HOME']}/.github_token"
  AUTH_LOCAL_FILE = ".github_token"
  SCOPES = "repo:status"

  attr_accessor :github, :scopes

  def self.new(scopes: SCOPES)
    Github::Api::Auth::Klass.new(scopes: scopes)
  end

  def initialize(scopes: [])
    @scopes = scopes
    authenticate
  end

  private

  def authenticate
    configure_from_file || basic_authentication
  end

  def basic_authentication
    login = ask('github username: ')
    password = ask('password: ') { |c| c.echo = false }
    self.github = Octokit::Client.new(login: login, password: password)
    token = create_access_token
    store_token(sanitize_token(token))
    configure_from_file
  end

  def configure_from_file
    path = File.exists?(AUTH_LOCAL_FILE) ? AUTH_LOCAL_FILE : AUTH_FILE
    config = YAML.load_file(path)
    self.github = Octokit::Client.new(access_token: config[:token])
    true
  rescue
    false
  end

  def create_access_token
    note = gen_token_note
    github.create_authorization(scopes: scopes, note: note)
  rescue Octokit::OneTimePasswordRequired => e
    otp = ask('one time password required: ')
    github.create_authorization(scopes: scopes, note: note, headers: { 'X-GitHub-OTP' => otp })
  end

  def store_token(token)
    File.open(AUTH_LOCAL_FILE, 'w') { |f| f.write(token.to_yaml) }
  end

  def sanitize_token(token)
    token.to_h.reject { |k, v| k == :app }
  end

  def gen_token_note
    # TODO Make this use existing token instead of creating new one
    # NOTE We need this number if user want to authenticate multiple devices
    number = Time.now.to_i
    "github-api-auth authorization #{number}"
  end
end
