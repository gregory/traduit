describe Traduit do
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

  describe '#t(key, options)' do
    let(:klass) { build_translatable_class(options, *scopes, &block) }
    let(:backend) { double(:backend) }
    let(:scopes) { [:foo] }
    let(:block) { ->{} }
    let(:translate_key) { 'foo.bar' }
    let(:key) { 'bar' }
    let(:params) { { key: :value } }

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
  end
end
