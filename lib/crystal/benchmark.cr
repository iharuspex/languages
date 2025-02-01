module Enumerable
    def variance
      mean = self.sum / self.size
      sum = self.reduce(0) { |acc, cur| acc + (cur-mean) ** 2 }
      sum/(self.size - 1).to_f
    end

    def std_dev
      Math.sqrt(self.variance)
    end
end

def bench(run_ms : Int32, warmup? : Bool = false, &fn)
	times = Array(Int32).new
	result = 0
	while(times.sum < run_ms && !(times.sum == 0 && times.size > 0))
		a = Time.measure {result = yield}
		times << a.milliseconds
	end

	# mean_ms,std-dev-ms,min_ms,max_ms,times,result
	unless times.empty? || warmup?
		puts "#{times.sum / times.size},#{times.std_dev},#{times.min},#{times.max},#{times.size},#{result}"
	end
end