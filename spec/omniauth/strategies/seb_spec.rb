require 'spec_helper'

describe OmniAuth::Strategies::Seb do
  PUBLIC_CRT = File.read(File.join(RSpec.configuration.cert_folder, 'response.public.pem'))
  SND_ID = 'AAA'

  let(:app){ Rack::Builder.new do |b|
    b.use Rack::Session::Cookie, {secret: 'abc123'}
    b.use OmniAuth::Strategies::Seb, PUBLIC_CRT, SND_ID
    b.run lambda{|env| [404, {}, ['Not Found']]}
  end.to_app }

  context 'request phase' do
    before(:each) { get '/auth/seb' }

    it 'displays a single form' do
      expect(last_response.status).to eq(200)
      expect(last_response.body.scan('<form').size).to eq(1)
    end

    it 'has JavaScript code to submit the form after it is created' do
      expect(last_response.body).to be_include('</form><script type="text/javascript">document.forms[0].submit();</script>')
    end

    EXPECTED_VALUES = {
      'IB_SND_ID': SND_ID,
      'IB_SERVICE': OmniAuth::Strategies::Seb::AUTH_SERVICE,
      'IB_LANG': 'LAT'
    }

    EXPECTED_VALUES.each_pair do |k,v|
      it "has hidden input field #{k} => #{v}" do
        expect(last_response.body).to include(
          "<input type=\"hidden\" name=\"#{k}\" value=\"#{v}\""
        )
      end
    end
  end

  context 'callback phase' do
    let(:auth_hash){ last_request.env['omniauth.auth'] }

    context "with valid response" do
      before do
        post '/auth/seb/callback',
          'IB_SND_ID': 'SEBUB',
          'IB_SERVICE': '0001',
          'IB_REC_ID': 'AAA',
          'IB_USER': '050505-12123',
          'IB_DATE': '05.12.2003',
          'IB_TIME': '10:00:00',
          'IB_USER_INFO': 'ID=050505-12123;NAME=JOHN DOE',
          'IB_VERSION': '001',
          'IB_CRC': 'abc',
          'IB_LANG': 'LAT'
      end

      it 'sets the correct uid value in the auth hash' do
        expect(auth_hash.uid).to eq('050505-12123')
      end

      it 'sets the correct info.full_name value in the auth hash' do
        expect(auth_hash.info.full_name).to eq('JOHN DOE')
      end
    end

    context 'with non-existant public key file' do
      let(:app){ Rack::Builder.new do |b|
        b.use Rack::Session::Cookie, {secret: 'abc123'}
        b.use(OmniAuth::Strategies::Seb, 'missing-public-key-file.pem', SND_ID )
        b.run lambda{|env| [404, {}, ['Not Found']]}
      end.to_app }

      it 'redirects to /auth/failure with appropriate query params' do
        post '/auth/seb/callback' # Params are not important, because we're testing public key loading
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq('/auth/failure?message=public_crt_load_err&strategy=seb')
      end
    end

    context 'with non-existant SND ID' do
      let(:app){ Rack::Builder.new do |b|
        b.use Rack::Session::Cookie, {secret: 'abc123'}
        b.use(OmniAuth::Strategies::Seb, PUBLIC_CRT, nil )
        b.run lambda{|env| [404, {}, ['Not Found']]}
      end.to_app }

      it 'redirects to /auth/failure with appropriate query params' do
        post '/auth/seb/callback' # Params are not important, because we're testing public key loading
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to eq('/auth/failure?message=invalid_response_snd_id_err&strategy=seb')
      end
    end

    context "with invalid MAC" do
      before do
        post '/auth/seb/callback',
        'IB_SND_ID': 'SEBUB',
        'IB_SERVICE': '0001',
        'IB_REC_ID': 'AAA',
        'IB_USER': '050505-12123',
        'IB_DATE': '05.12.2003',
        'IB_TIME': '10:00:00',
        'IB_USER_INFO': 'ID=050505-12123;NAME=JOHN DOE',
        'IB_VERSION': '001',
        'IB_CRC': 'abc',
        'IB_LANG': 'LAT'
      end

      it "fails with invalid_mac error" do
        expect(auth_hash).to eq(nil)
        expect(last_request.env['omniauth.error.type']).to eq(:invalid_response_snd_id_err)
      end
    end

  end

end
