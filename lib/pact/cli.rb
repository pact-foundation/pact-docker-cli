require "pact/cli/version"
require 'pact_broker/client/cli/broker'
require 'pactflow/client/cli/pactflow'
require 'pact/provider_verifier/cli/verify'
require 'pact/mock_service/cli'

class Thor
  module Base
    module ClassMethods
      def basename
        argv = ARGV.dup
        argv.delete("help")
        if ENV['DOCKER']
          argv.unshift # remove "pact"
          argv.first || ""
        else
          argv.first || "pact"
        end
      end
    end
  end
end

module Pact
  class AggregatedCLI < Thor
    HELP = ["help", "--help", "-h"]

    desc 'mock-service', '(legacy) Run a Pact mock service'
    def mock_service
      ::Pact::MockService::CLI.start(process_argv("mock-service"))
    end

    desc 'stub-service', '(legacy) Run a Pact stub service'
    def stub_service
      require 'pact/stub_service/cli'
      Pact::StubService::CLI.start(process_argv("stub-service"))
    end

    desc 'pact-broker', '(legacy) Interact with a Pact Broker (also aliased as the subcommand `broker`) - use `pact-broker-cli` subcommand instead'
    def pact_broker
      ::PactBroker::Client::CLI::Broker.start(process_argv("pact-broker"))
    end

    desc 'broker', '(legacy) Interact with a Pact Broker (this command is still supported by has been superseded by the pact-broker command for consistency across the various packages - use `pact-broker-cli` subcommand instead', hide: true
    def broker
      ::PactBroker::Client::CLI::Broker.start(process_argv("broker"))
    end

    desc 'pactflow', '(legacy) Interact with PactFlow - use `pact-broker-cli pactflow` subcommand instead'
    def pactflow
      ::Pactflow::Client::CLI::Pactflow.start(process_argv("pactflow"))
    end

    desc 'verify PACT_URL ...', "(legacy) " + Pact::ProviderVerifier::CLI::Verify.commands["verify"].description
    long_desc Pact::ProviderVerifier::CLI::Verify.commands["verify"].long_description

    def verify
      argv = ARGV.dup
      while argv.any? && !argv.first.start_with?("-")
        argv.shift
      end
      ENV["PACT_INTERACTION_RERUN_COMMAND"] ||= "PACT_DESCRIPTION=\"<PACT_DESCRIPTION>\" PACT_PROVIDER_STATE=\"<PACT_PROVIDER_STATE>\" #{$PROGRAM_NAME} verify <PACT_URI> #{argv.join(" ")}"

      Pact::ProviderVerifier::CLI::Verify.start(process_argv(""))
    end

    desc ::PactBroker::Client::CLI::Broker.commands["publish"].usage, "(legacy) " + ::PactBroker::Client::CLI::Broker.commands["publish"].description
    long_desc ::PactBroker::Client::CLI::Broker.commands["publish"].long_description

    def publish
      ::PactBroker::Client::CLI::Broker.start(process_argv(""))
    end

    desc 'publish-cli', 'Publish pacts to a Pact Broker.'
    def publish_cli
      ARGV.shift
      output = `./bin/pact-broker-cli publish #{ARGV.join(" ")}`
      exit_status = $?.exitstatus
      puts output
      exit(exit_status)
    end

    desc "version", "Print the version of the CLI"
    def version
      require 'pact/cli/version'
      puts Pact::Cli::VERSION
    end
    desc 'plugin', 'Run the Pact plugin cli'
    def plugin
      ARGV.shift
      output = `./bin/pact-plugin-cli #{ARGV.join(" ")}`
      exit_status = $?.exitstatus
      puts output
      exit(exit_status)
    end
    desc 'verifier', 'Verify pact(s) against a provider. Supports local and networked (http-based) files.'
    def verifier
      ARGV.shift
      output = `./bin/pact_verifier_cli #{ARGV.join(" ")}`
      exit_status = $?.exitstatus
      puts output
      exit(exit_status)
    end
    desc 'mock-server', 'Run a Pact mock server'
    def mock_server
      ARGV.shift
      IO.popen(["./bin/pact_mock_server_cli", *ARGV], err: [:child, :out]) do |io|
        while (line = io.gets)
          $stdout.write(line)
        end
        exit_status = Process.wait2(io.pid)[1].exitstatus
        exit(exit_status)
      end
    end
    desc 'stub-server', 'Run a Pact stub server'
    def stub_server
      ARGV.shift
      IO.popen(["./bin/pact-stub-server", *ARGV], err: [:child, :out]) do |io|
        while (line = io.gets)
          $stdout.write(line)
        end
        exit_status = Process.wait2(io.pid)[1].exitstatus
        exit(exit_status)
      end
    end
    desc 'pact-broker-cli', 'Interact with a Pact Broker'
    def broker_cli
      ARGV.shift
      output = `./bin/pact-broker-cli #{ARGV.join(" ")}`
      exit_status = $?.exitstatus
      puts output
      exit(exit_status)
    end
    no_commands do
      def self.exit_on_failure?
        true
      end

      def process_argv(subcommand)
        is_help = (ARGV & HELP).any?
        argv = ARGV - [subcommand] - HELP
        argv.unshift("help") if is_help
        argv
      end
    end
  end
end