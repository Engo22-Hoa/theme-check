# frozen_string_literal: true
require "pp"
require "timeout"

module ThemeCheck
  class Checks < Array
    CHECK_METHOD_TIMEOUT = 5 # sec

    def call(method, *args)
      each do |check|
        call_check_method(check, method, *args)
      end
    end

    def disableable
      self.class.new(select(&:can_disable?))
    end

    private

    def call_check_method(check, method, *args)
      return unless check.respond_to?(method) && !check.ignored?

      Timeout.timeout(CHECK_METHOD_TIMEOUT) do
        template = extract_template(args) if ThemeCheck.trace?
        ThemeCheck.trace("Running #{check.code_name}##{method} on #{template}") do
          check.send(method, *args)
        end
      end
    rescue Liquid::Error
      # Pass-through Liquid errors
      raise
    rescue => e
      node = args.first
      template = extract_template(args)
      markup = node.respond_to?(:markup) ? node.markup : ""
      node_class = node.respond_to?(:value) ? node.value.class : "?"

      ThemeCheck.bug(<<~EOS)
        Exception while running `#{check.code_name}##{method}`:
        ```
        #{e.class}: #{e.message}
          #{e.backtrace.join("\n  ")}
        ```

        Template: `#{template}`
        Node: `#{node_class}`
        Markup:
        ```
        #{markup}
        ```
        Check options: `#{check.options.pretty_inspect}`
      EOS
    end

    def extract_template(args)
      node = args.first
      node.template.relative_path.to_s if node.respond_to?(:template)
    end
  end
end
