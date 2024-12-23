
Rebilling test task

## Prerequisites

- **Ruby**: `>= 3.2.6`

- **Redis**: Running locally or remotely for Sidekiq.

- **SQLite**: For database management.

- **Gems**:

- `sidekiq`

- `sidekiq-scheduler`

- `active_record`

- `money`

- `rspec` (for testing)

- `rubocop` (for code style)

---

## Setup

### 1. Install Dependencies

Run the following command to install required gems:

```bash

bundle install

```

### 2. Set Up the Database

Run migrations to create necessary tables:

```bash

rake db:create db:migrate

```

### 3. Start Redis

Ensure Redis is running. You can start it with:

```bash

redis-server

```

### 4. Start Sidekiq

Run Sidekiq and point it to the `sidekiq_worker.rb` file:

```bash

sidekiq -r  ./sidekiq_worker.rb

```

## Usage

### Add a Payment Record

You can create a new payment record using IRB:

```ruby

require_relative 'services/create_payment_service'



CreatePaymentService.create_payment(amount: 100, subscription_id: 'test')

```




### Trigger Rebilling Job



Manually enqueue a job to process a payment:



```ruby

require  './jobs/rebill_job'



RebillJob.perform_async(payment.id)

```

### Get Logs about your subscription

Manually enqueue a job to process a payment:

```ruby

require_relative 'services/logger_service'

LoggerService.find_logs(subscription_id: 'test')

{:subscription_id=>"test",
 :retry_at=>nil,
 :total_amount=>100,
 :remaining_amount=>0,
 :created_at=>2024-12-23 22:55:47.699389 UTC,
 :payment_attempts=>[{:status=>"success", :charge_amount=>88, :created_at=>2024-12-23 22:55:47.714726 UTC}]}

```



### Scheduled Jobs



The app uses **Sidekiq Scheduler** to automate recurring tasks defined in `config/schedule.yml`. Example configuration:



```yaml

rebill_job:

cron: "0 0 * * *"  # Runs daily at midnight

class: "RebillJob"

queue: default

args:

- payment_id

```



---



## Testing



Run RSpec tests:



```bash

rspec

```


