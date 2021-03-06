##GruntMerge

[![Build Status](https://travis-ci.org/winton/grunt-merge.png)](https://travis-ci.org/winton/grunt-merge) [![NPM version](https://badge.fury.io/js/grunt-merge.png)](http://badge.fury.io/js/grunt-merge)

Grunt task that merges git branches for you.

###Install

    npm install grunt-merge

###Example Gruntfile

    module.exports = (grunt) ->
      grunt.config.data.merge =
        'a-b': [ 'a', 'b' ]

      grunt.task.loadTasks path.resolve(__dirname, "../node_modules/grunt-merge/lib")

This example creates a new branch (`a-b`) and then sequentially merges branches `a` and `b` into it.

Run `grunt merge` to execute your merges.

###Conflicts

If there are merge conflicts, the task stops and allows you to fix them.

When you're finished, run `grunt merge` again.

### Stay up to date

[Watch this project](https://github.com/winton/grunt-merge#) on Github.

[Follow Winton Welsh](http://twitter.com/intent/user?screen_name=wintonius) on Twitter.
