    local database = 'http://vip.opload.ir/vipdl/95/3/amirab248/'
    local function run(msg)
      local res = http.request(database.."koskesh.db")
     local kalkal = res:split(",")
     return kalkal[math.random(#kalkal)]
    end
    return {
     patterns = {
      "(.*)",
    "%[(photo)%]",
    "%[(document)%]",
    "%[(video)%]",
    "%[(audio)%]",
      },
     run = run
    }
     
     
    -- by THISISAMIRHOSEEIN :D