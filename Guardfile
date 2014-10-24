# A sample Guardfile
# More info at https://github.com/guard/guard#readme
guard :shell do
  watch(/.*\.adoc/) { `rake build_reveal` }
end
guard 'livereload' do
  watch(/.*.html/)
end
