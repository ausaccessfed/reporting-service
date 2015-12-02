unless ENV['AAF_DEV'].to_i == 1
  $stderr.puts <<-EOF

  This is a destructive action, intended only for use in development
  environments where you wish to replace ALL data with generated sample data.

  If this is what you want, set the AAF_DEV environment variable to 1 before
  attempting to seed your database.

  EOF
  fail('Not proceeding, missing AAF_DEV=1 environment variable')
end
