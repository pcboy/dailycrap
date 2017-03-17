require "dailycrap/version"

require 'github_api'
require 'active_support/core_ext/object/try'

require 'awesome_print'

module Dailycrap
  class Dailycrap

    def initialize(token, date: Date.today - 1, repo:, user: nil, organization: nil)
      @token = token
      @user = user || github.users.get.login

      if organization.nil? && organizations.count > 1
        warn "You have more than one organization (#{organizations}), please choose one as parameter or we'll use your personal one"
      end
      @organization = organization || @user 
      @repo = repo
      @date = date
    end

    def daily
      worked_on_prs = []
      closed_prs = []
      reviewed_prs = []

      in_progress_issues = iterate(github.issues) do |iterator|
        iterator.list(user: @organization, repo: @repo, state: 'open', labels: 'in progress')
      end.select{|x| (x.assignee ? x.assignee.login : (x.pull_request ? x.user.login : nil)) == @user }.map{|x| x.title}

      events(@date).map do |event|
        case event.type
        when 'PushEvent' 
          if event.payload.ref != 'refs/heads/master'
            pr = pr_from_ref(event.payload.ref) || {title: event.payload.ref.gsub('refs/heads/', '')}
            worked_on_prs << pr
          end
        when 'CreateEvent'
          # Created a new branch
        when 'IssuesEvent'
        when 'PullRequestReviewCommentEvent'
          unless event.payload.pull_request.assignees.map(&:login).include?(@user)
            reviewed_prs << event.payload.pull_request.title
          end
        when 'PullRequestEvent'
          if event.payload.action == 'closed' && event.payload.pull_request.assignees.map(&:login).include?(@user)
            closed_prs << event.payload.pull_request.title
          end
        else
          STDERR.puts "#{event.type} not supported yet"
        end
      end

      format_daily(worked_on_prs, closed_prs, in_progress_issues, reviewed_prs)
    end

    def events(date)
      events = github.activity.events.performed(@user)
      iterate(events, date: date, behavior: :at_date) do |iterator|
        iterator.body
      end.select{|x| x.repo.name.split('/').last == @repo}
    end

    private

    def format_daily(worked_on_prs, closed_prs, in_progress, reviewed_prs)
      %Q{
        #{(@date.friday? && Date.today.monday?) ? 'Friday' : 'Yesterday'}
        \tWorked on:
        \t\t#{worked_on_prs.map{|x| (closed_prs.include?(x[:title]) ? '[DONE :tada:] ' : '') + x[:title]}.uniq.join("\n\t\t")}

        \tReviewed:
        \t\t#{reviewed_prs.uniq.join("\n\t\t")}
        
        Today:
        \tIn progress:
        \t\t#{in_progress.uniq.join("\n\t\t")}
      }.gsub(/^ +/, '')
    end

    def pr_from_ref(ref)
      prs = iterate(github.pull_requests, date: @date, behavior: :from_date) do |iterator|
        iterator.list(user: @organization, repo: @repo, state: 'all')
      end.map{|x| {ref: x.head.ref, title: x.title, created_at: x.created_at, merged_at: x.merged_at, href: x['_links']['self']['href'] }}
      prs.find{|x| x[:ref] == ref.gsub('refs/heads/', '')}
    end

    def organizations
      @_orgz ||= github.organizations.list.map{|x| x.login}
    end

    def github
      @_github ||= Github.new oauth_token: @token
    end

    def iterate(iterator, date: nil, behavior: :at_date)
      total_events = []
      begin
        data = yield(iterator)
        total_events += data
        break if date && data.any?{|x| Date.parse(x.updated_at || x.created_at) < date}
        iterator = iterator.try(:next_page)
      end while iterator && iterator.has_next_page?
      if date
        if behavior == :at_date
          total_events.select!{ |x| Date.parse(x.updated_at || x.created_at) == date }
        elsif behavior == :from_date
          total_events.select!{ |x| Date.parse(x.updated_at || x.created_at) >= date }
        end
      end
      total_events
    end
  end
end
