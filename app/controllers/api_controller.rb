class ApiController < ApplicationController
  include Redis::Objects
  before_action :get_timeout, except: [:open, :job]
  #key UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, userid).to_s.gsub('-','')
  #客户端发起任务
  def open
    uid = params[:uid]
    pass = params[:pass]
    key = params[:key]
    if User.haskey? key
      sid = UUIDTools::UUID.timestamp_create.to_s.gsub('-','')
      redis.set(sid, "#{uid}|#{pass}")
      redis.expire(sid, 160)
      redis.rpush("data", sid)
      render text: sid
      return
    end
    render text: "error"
  end

  #客户端请求结果
  def result
    bfstr = redis.get "result:#{@sid}"
    if bfstr
      render text: bfstr
      return
    end
    if @timeout == -1
      render text: "timeout"
      return
    end
    render text: "wait"
  end

  #后台程序请求处理任务
  def job
    sid = redis.lpop "data"
    if sid.nil?
      render text: "nojob"
      return
    end
    timeout = redis.ttl sid
    if timeout > 20
      render text: "#{sid}|#{redis.get(sid)}"
      return
    end
    render text: "timeoutjob"
  end

  #后台程序处理结果返回
  def jobresult
    bfstr = params[:bfstr]
    redis.set "result:#{@sid}", bfstr
    render text: "ok"
  end

  private
  def get_timeout
    @sid = params[:sid]
    @timeout = redis.ttl @sid
  end
end
