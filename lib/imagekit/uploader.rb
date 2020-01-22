require 'rest_client'
require 'json'

class Imagekit::Uploader
  REMOTE_URL_REGEX = %r(^ftp:|^https?:|^s3:|^data:[^;]*;base64,([a-zA-Z0-9\/+\n=]+)$)
  UPLOAD_URL = 'https://upload.imagekit.io/rest/api/image/v2/'

  def self.build_upload_params(options)
    params = {
      file:              options[:file],
      filename:          options[:filename],
      apiKey:            Imagekit.configuration.public_key,
      signature:         @signature,
      timestamp:         Time.now.to_i,
      useUniqueFilename: options[:use_unique_filename],
      folder:            options[:folder]
    }
  end

  def self.upload(file, options={})
    call_api("upload", options) do
      params = build_upload_params(options)

      if file.is_a?(Pathname)
        params[:file] = File.open(file, "rb")
      elsif file.respond_to?(:read) || file.match(REMOTE_URL_REGEX)
        params[:file] = file
      else
        params[:file] = File.open(file, "rb")
      end
      [params, [:file]]
    end
  end

  def self.call_api(action, options)
    options      = options.clone
    return_error = options.delete(:return_error)

    params, non_signable = yield
    non_signable         ||= []

    result = nil
    signature                = Imagekit.generate_signature(params.slice(:apiKey, :filename, :timestamp))
    params[:signature]       = signature
    api_url                  = Imagekit::Uploader::UPLOAD_URL + Imagekit.configuration.imagekit_id
    headers                  = { "User-Agent" => Imagekit::USER_AGENT }
    headers['Content-Type']  = options[:content_type] || 'multipart/form-data'
    headers.merge!(options[:extra_headers]) if options[:extra_headers]
    
    RestClient::Request.execute(method: :post, url: api_url, payload: params.reject { |k, v| v.nil? || v == "" }, timeout: 60, headers: headers) do
    |response, request, tmpresult|
      raise Imagekit::ImagekitException, "Server returned unexpected status code - #{response.code} - #{response.body}" unless [200, 400, 401, 403, 404, 500].include?(response.code)
      begin
        result = JSON.parse(response.body)
      rescue => e
        # Error in json parsing
        raise Imagekit::ImagekitException, "Error parsing server response (#{response.code}) - #{response.body}. Got - #{e}"
      end
      if result["error"]
        if return_error
          result["error"]["http_code"] = response.code
        else
          raise Imagekit::ImagekitException, result["error"]["message"]
        end
      end
    end

    result
  end

end
