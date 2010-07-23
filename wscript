#!/usr/bin/python

VERSION='0.0.1'
APPNAME='test'
srcdir = './'
blddir = 'build'

import Options

def set_options(opt):
	print '\nSetting build options & flags...'
	opt.tool_options('compiler_cc')
	opt.tool_options('vala')


def init():
	print 'Initializing WAF build system...'

def configure(conf):
	print 'Configuring the build enviroment...'
	conf.check_tool('compiler_cc')
	conf.check_tool('vala')
	
	conf.env.append_value('CFLAGS', ['-O2', '-g'])
	conf.env.append_value('VALAFLAGS', '--thread --save-temps -X -Wall')
	
	conf.check_cfg(package='gee-1.0', uselib_store='GEE', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='gtk+-2.0', uselib_store='GTK', atleast_version='2.10.0', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='jack', uselib_store='JACK', atleast_version='0.100', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='sndfile', uselib_store='SNDFILE', mandatory=1, args='--cflags --libs')

def build(bld):
	print 'Building the sources to objects...'
	
	bld.new_task_gen(
		features = 'cc cstaticlib',
		packages = 'gtk+-2.0',
		target = 'waveview',
		source = 'waveview.vala',
		uselib = 'GTK',
		)
	
	bld.new_task_gen(
		features = 'cc cstaticlib',
		packages = 'sndfile jack',
		target = 'sample',
		source = 'sample.vala',
		uselib = 'SNDFILE',
		)
	
	bld.new_task_gen(
		features = 'cc cstaticlib',
		packages = 'jack gee-1.0',
		target = 'mixer',
		source = 'mixer.vala',
		uselib = 'JACK GEE',
		uselib_local = 'sample waveview')
	
	bld.new_task_gen(
		features = 'cc cstaticlib',
		packages = 'jack gtk+-2.0',
		target = 'jackclient',
		source = 'jack.vala',
		uselib = 'JACK GTK',
		uselib_local = 'mixer',
		)
	
	bld.new_task_gen(
		features = 'cc cstaticlib',
		packages = 'jack',
		target = 'engine',
		source = 'engine.vala',
		uselib = 'JACK',
		uselib_local = 'mixer jackclient')
	
	bld.new_task_gen(
		features = 'cc cstaticlib',
		packages = 'gtk+-2.0 gee-1.0',
		target = 'mainwindow',
		source = 'mainwindow.vala',
		uselib = 'GTK GEE',
		uselib_local = 'waveview',)
	
	bld.new_task_gen(
		features = 'cc cprogram',
		packages = 'gtk+-2.0 jack sndfile',
		target = 'main',
		includes= '/usr/include',
		source = 'main.vala',
		uselib = 'GTK GLIB JACK SNDFILE',
		uselib_local = 'mainwindow engine',
		)

def shutdown():
	print('')
