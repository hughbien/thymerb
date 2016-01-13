module Thyme
  class Error < StandardError; end # catch all error for Thyme
  class StopTimer < StandardError; end # used to stop repeat timers
end
