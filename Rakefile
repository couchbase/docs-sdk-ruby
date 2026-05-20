desc "Check syntax of all Ruby example files (equivalent to running `ruby -c` on each file)"
task :check_syntax do
  pass = 0
  fail_count = 0
  errors = []

  Dir.glob("modules/**/*.rb").sort.each do |file|
    source = File.read(file)
    RubyVM::InstructionSequence.compile(source, file)
    pass += 1
  rescue SyntaxError => e
    fail_count += 1
    errors << file
    puts "FAIL: #{e.message}"
  end

  puts "\nResults: #{pass} files passed, #{fail_count} failed"

  abort "Files with errors:\n#{errors.map { |f| "  #{f}" }.join("\n")}" if errors.any?
end
