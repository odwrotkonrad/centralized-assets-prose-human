package example

import "time"

///[>] client

const baseURL = "https://api.example.io/v2" //[where] https://api.example.io/docs

var timeout = 5 * time.Second //[why] p99 latency is 3s: headroom without hanging callers

////[>] retry 🤖🤖

//>[what]
//   exponential backoff with full jitter,
//   attempts capped so total wait stays under timeout
///[what]

func retryDelay(attempt int) time.Duration {
	return time.Duration(1<<attempt) * 100 * time.Millisecond //[what] 100ms, 200ms, 400ms, ...
}

////[<] retry 🤖🤖

///[<] client
