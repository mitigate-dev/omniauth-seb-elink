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
          "B02K_ALG": "01",
          "B02K_CUSTID": "37404280367",
          "B02K_CUSTNAME": "RAITUMS ARNIS",
          "B02K_CUSTTYPE": "01",
          "B02K_IDNBR": "87654321LV",
          "B02K_KEYVERS": "0001",
          "B02K_MAC": "B2B82821F6EB9CA28E4D67F343914363",
          "B02K_STAMP": "yyyymmddhhmmssxxxxxx",
          "B02K_TIMESTMP": "20020170329134514398",
          "B02K_VERS": "0002"
      end

      it 'sets the correct uid value in the auth hash' do
        expect(auth_hash.uid).to eq("374042-80367")
      end

      it 'sets the correct info.full_name value in the auth hash' do
        expect(auth_hash.info.full_name).to eq("ARNIS RAITUMS")
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

    context "with invalid MAC" do
      before do
        post '/auth/seb/callback',
          "B02K_ALG": "01",
          "B02K_CUSTID": "37404280367",
          "B02K_CUSTNAME": "RAITUMS ARNIS",
          "B02K_CUSTTYPE": "01",
          "B02K_IDNBR": "87654321LV",
          "B02K_KEYVERS": "0001",
          "B02K_MAC": "B9CA28E4D67F343914B2B82821F6E363",
          "B02K_STAMP": "yyyymmddhhmmssxxxxxx",
          "B02K_TIMESTMP": "20020170329134514398",
          "B02K_VERS": "0002"
      end

      it "fails with invalid_mac error" do
        expect(auth_hash).to eq(nil)
        expect(last_request.env['omniauth.error.type']).to eq(:invalid_mac)
      end
    end

  end

end
