    local function offlineteam(msg, matches)
     
    local url = io.popen("curl http://thisisamir.xzn.ir/file/time/time3.php "):read('*all')
     
      return url
     
    end
     
    return {
     
      patterns = {
     
        '^[/!#][Dd]ate$',
     
      },
     
      run = offlineteam
     
    }