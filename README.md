# AAF Reporting Service

```
Copyright 2015, Australian Access Federation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

AAF Reporting Service generates reports and graphs from data sourced from:

* Federation Registry
* Rapid Connect
* Discovery Service
* Other AAF infrastructure, as needed

## Setting up a development environment

1. Be using Ruby 2.2+
2. `brew install phantomjs`
3. `bin/setup` (and read the output for any additional steps)
4. `guard`

## Running tests in development environment
1. `RAILS_ENV=test bundle exec rake db:reset` to reset the database
2. `RAILS_ENV=test bundle exec rake` to run test suite
