class Traduit < Module
  DEFAULT_BACKEND = :default
  DEFAULT_METHOD  = :t
  VERSION         = "0.0.1"

  attr_reader :options

  def initialize(*scopes, &block)
    options = scopes[0].is_a?(Hash) ? scopes.shift : {}
    @options = (options).merge(scope: scopes.compact, block: block)
    tap do |mod|
      mod.define_singleton_method :included do |klass|
        super(klass)
        klass.define_singleton_method :__traduit_options__ do
          mod.options
        end
        klass.send :include, InstanceMethods
        klass.extend ClassMethods
      end
    end
  end

  class<<self
    def backend=(value)
      backends[DEFAULT_BACKEND] = value
    end

    def backends
      @backends ||= flush
    end

    def flush
      @backends = {}
    end
  end

  module ClassMethods
    def traduit(*scopes, &block)
      options = scopes[0].is_a?(Hash) ? scopes.shift : {}
      options = (options).merge(scope: scopes.flatten.compact, block: block)

      define_singleton_method :__traduit_options__ do
        options
      end
    end
  end

  module InstanceMethods
    def t(key, options={})
      namespace = options.delete(:namespace)
      namespace = namespace.nil? ? __traduit_namespace__ : Array(namespace)
      block = options[:scope].nil? ? __traduit_block__ : []
      defaults = {
        scope: (namespace | __traduit_scope__ | block).flatten.compact
      }
      backend = Traduit.backends[__traduit_backend__]
      backend.send(__traduit_method__, key, defaults.merge(options))
    end

    private

    def __traduit_backend__
      @__traduit_backend__ ||= self.class.__traduit_options__[:backend] || Traduit::DEFAULT_BACKEND
    end

    def __traduit_method__
      @__traduit_method__ ||= self.class.__traduit_options__[:method] || Traduit::DEFAULT_METHOD
    end

    def __traduit_namespace__
      @__traduit_namespace__ ||= Array(self.class.__traduit_options__[:namespace])
    end

    def __traduit_scope__
      @__traduit_scope__ ||= Array(self.class.__traduit_options__[:scope])
    end

    def __traduit_block__
      block = self.class.__traduit_options__[:block]
      return [] unless block
      Array(block.arity > 0 ? block.call(self) : block.call)
    end
  end
end
