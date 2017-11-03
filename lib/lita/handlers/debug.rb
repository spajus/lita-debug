module Lita
  module Handlers
    class Debug < Handler
      config :enable_eval
      config :restrict_eval_to
      config :restrict_debug_to

      on(:connected) do
        if config.enable_eval
          self.class.route(
            /^eval (.+)$/,
            :do_eval,
            command: true,
            restrict_to: config.restrict_eval_to || :admins,
            help: { 'eval <something>' => 'evals ruby object from within the handler (DANGER, raw unsafe eval!!!)' }
          )
        end

        self.class.route(
          /^debug$/,
          :debug,
          command: true,
          restrict_to: config.restrict_debug_to || :admins,
          help: { 'debug' => 'Prints a bunch of lita debug information in current context' }
        )
      end

      def do_eval(response)
        query = response.matches[0][0]
        result = begin
                   eval(query).inspect
                 rescue => e
                   "Could not eval your command: #{e}"
                 end
        response.reply(result)
      end

      def debug(response)
        output = {}
        output[:server] = { hostname: `hostname`.strip }
        output[:room] = response.room
        output[:user] = response.user
        response.reply(output.to_yaml)
      end

      Lita.register_handler(self)
    end
  end
end
