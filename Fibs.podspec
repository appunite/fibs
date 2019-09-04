Pod::Spec.new do |s|
  s.name         = "Fibs"
  s.version      = "0.0.3"
  s.summary      = "Mock endpoints & execute commands"
  s.description  = <<-DESC
  Library for mocking network traffic and executing shell commands locally from running app.
                   DESC
  s.homepage     = "https://git.appunite.com/szymon.mrozek/fibs"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }

  s.authors      = { "Damian Kolasiński" => "damian.kolasinski@appunite.com", "Szymon Mrozek" => "szymon.mrozek.sm@gmail.com" }
  s.source       = { :http => "https://git.appunite.com/szymon.mrozek/fibs/-/jobs/481031/artifacts/raw/fibs.zip" }

  s.preserve_paths = '*'
  s.exclude_files = "**/file.zip"
end
