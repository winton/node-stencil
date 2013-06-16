for key, value of require('./stencil/common')
  eval("var #{key} = value;")

module.exports = (grunt) ->
  config = grunt.config("stencil") || {}
  config = grunt.file.readJSON(config.json || "stencil.json")

  grunt.util.branches = ->
    grunt.util.cmd("git branch -a").then(
      (output) ->
        output.split(/[\s\*]+/).slice(1)
    )

  grunt.util.checkoutCmd = (branch, create_from) ->
    grunt.util.branches().then (branches) ->
      if branches.indexOf(branch) > -1
        "git checkout #{branch}"
      else if branches.indexOf("origin/#{branch}") > -1
        "git checkout -t origin/#{branch}"
      else if create_from
        grunt.util.checkoutCmd(create_from).then (co) ->
          [
            co
            "git branch #{branch}"
            "git checkout #{branch}"
          ]
      else
        throw "Cannot checkout branch that does not exist"

  grunt.util.cmd = (cmd) ->
    return Q.resolve(@last_result)  if @last_cmd == cmd
    [ promise, resolve, reject ] =  defer()

    og   = cmd
    args = cmd.split(/\s+/)
    cmd  = args.shift()

    grunt.util.spawn(
      cmd : cmd
      args: args

      (error, result, code) =>
        if error
          console.log("#{og}\n")
          grunt.log.error(result)
          console.log("")

          reject(error)
        else
          @last_cmd    = og
          @last_code   = code
          @last_result = result.toString()

          resolve(@last_result, @last_code)
    )

    promise

  grunt.util.cmds = (cmds...) ->
    unless cmds instanceof Array
      cmds = [ cmds ]

    _.inject(
      _.flatten(cmds)
      (promise, cmd) -> grunt.util.cmd(cmd)
      Q.resolve()
    )

  grunt.registerTask("stencil:merge", "Merge template branches.", ->
    branches = []
    done     = @async()
    promise  = grunt.util.cmd("git fetch --all")

    _.each config, (value, key) ->
      promise = _.inject(
        value
        (promise, branch) =>
          promise.then(=>
            grunt.util.checkoutCmd(key, value[0])
          ).then((co) =>
            @co_key = co
            grunt.util.checkoutCmd(branch)
          ).then((co) =>
            grunt.util.cmds(co)
          ).then(=>
            unless grunt.option('offline')
              grunt.util.cmd("git pull origin #{branch}")
          ).then(=>
            grunt.util.cmds(@co_key, "git merge #{branch}")
          ).then(=>
            unless grunt.option('offline')
              grunt.util.cmd("git push #{key}")
          )
        promise
      )

    promise.then(
      -> grunt.log.success("Merge complete.")
      (e) ->
        throw e
        grunt.log.error("Please fix the conflict and run `grunt stencil:merge` again.")
    ).fin(
      done
    ).done()
  )

  grunt.task.registerTask("stencil:pull", "Update project from template.", ->)
  grunt.task.registerTask("stencil:push", "Push commit(s) to template.", ->)
  grunt.task.registerTask('stencil', [ 'stencil:pull' ])