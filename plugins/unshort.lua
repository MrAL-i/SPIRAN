    do
    local function run(msg, matches)
    if matches[1]:lower() == 'shorten' then
      local link = URL.escape(matches[2])
      url = "https://api-ssl.bitly.com/v3/shorten?access_token=f2d0b4eabb524aaaf22fbc51ca620ae0fa16753d&longUrl="..link
      jstr, res = https.request(url)
      jdat = JSON.decode(jstr)
      if jdat.message then
        return 'Base Link :n'..matches[2]..'n___________nShort Linkn'..jdat.message
      else
        return 'Base Link :n'..matches[2]..'n___________nShort Linkn'..jdat.data.url
        end
      end
      if matches[1]:lower() == 'unshorten' then
        local response_body = {}
       local request_constructor = {
          url = matches[2],
          method = "HEAD",
          sink = ltn12.sink.table(response_body),
          headers = {},
          redirect = false
       }
     
       local ok, response_code, response_headers, response_status_line = http.request(request_constructor)
       if ok and response_headers.location then
          return "Base Link :n" .. response_headers.location
       elseif not ok then
          return "Can't expand the url."
       end
    end
      end
     
    return {
      patterns = {
      "^[/#!]([Uu]nshorten) (.*)$",
      "^([Uu]nshorten) (.*)$",
      "^[Uu]nshorten (.*)$",
      "^[/#!]shorten (.*)$",
      },
      run = run,
    }
    end