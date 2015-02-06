describe Traduit do
  let(:translate_key) { 'foo.bar' }
  let(:key) { 'bar' }
  let(:params) { { key: :value } }

  describe '.backends' do
    let(:backends) { {} }

    subject { described_class.backends }

    context 'when empty backend' do
      it 'return empty backends' do
        expect(subject).to eq backends
      end
    end
  end

  describe '.backend=(value)' do
    let(:backend) { double(:backend) }

    before { described_class.backend = backend }
    subject { described_class.backends[:default] }

    it 'sets backend as the default backend' do
      expect(subject).to eq backend
    end
  end

  describe '.traduit(options, &block)' do
    let(:backend) { double(:backend) }
    let(:block) { ->(instance) { instance.object_id } }
    let(:namespace) { 'namespace2' }
    let(:scope) { [:foo, :bar ] }
    let(:new_options) { { namespace: namespace } }
    let(:options) { { namespace: 'namespace' } }
    let(:instance) { klass.new }

    before { described_class.backend = backend }

    let(:klass) { build_translatable_class(options, ['foo']) }

    subject { instance.t(key, params) }

    it { expect(klass).to respond_to(:traduit) }

    context 'when we overwrite the options' do
      before do
        klass.send(:traduit, new_options, scope, &block)
        scopes = [namespace] | scope | [block.call(instance)]
        expect(backend).to receive(:t).with(key, params.merge(scope: scopes))
          .and_return(translate_key)
      end

      it { expect(subject).to eq translate_key }
    end
  end

  describe '#t(key, options)' do
    let(:klass) { build_translatable_class(options, *scopes, &block) }
    let(:backend) { double(:backend) }
    let(:scopes) { [:foo] }
    let(:block) { ->{} }

    before { described_class.backend = backend }

    context 'when no options' do
      let(:options) {}

      before do
        expect(backend).to receive(:t).with(key, params.merge(scope: scopes))
          .and_return(translate_key)
      end
      subject { klass.new.t(key, params) }

      it { expect(subject).to eq translate_key }
    end

    context 'when namespace' do
      let(:namespace) { 'namespace' }
      let(:options) { { namespace: namespace } }

      before do
        expect(backend).to receive(:t)
          .with(key, params.merge(scope: [namespace] | scopes))
          .and_return(translate_key)
      end

      subject { klass.new.t(key, params) }

      it { expect(subject).to eq translate_key }
    end

    context 'when block' do
      let(:block) { ->(instance) { instance.object_id } }
      let(:options) { { block: block } }
      let(:instance) { klass.new }

      before do
        expect(backend).to receive(:t)
          .with(key, params.merge(scope: scopes | [block.call(instance)]))
          .and_return(translate_key)
      end

      subject { instance.t(key, params) }

      it { expect(subject).to eq translate_key }
    end

    context 'when scope is passed to t' do
      let(:namespace) { 'namespace' }
      let(:options) { { namespace: namespace } }
      let(:new_scope) { [:new, :scope] }
      let(:params) { {key: :value, scope: new_scope } }

      before do
        expect(backend).to receive(:t)
          .with(key, params.merge(scope: new_scope))
          .and_return(translate_key)
      end

      subject { klass.new.t(key, params) }

      it { expect(subject).to eq translate_key }
    end

    context 'when namespace is passed to t' do
      let(:namespace) { 'namespace' }
      let(:options) { { namespace: namespace } }
      let(:new_namespace) { :awesome }
      let(:params) { {key: :value } }

      before do
        expect(backend).to receive(:t)
          .with(key, params.merge(scope: [new_namespace] | scopes))
          .and_return(translate_key)
      end

      subject { klass.new.t(key, ({namespace: new_namespace}).merge(params)) }

      it { expect(subject).to eq translate_key }
    end
  end
end
