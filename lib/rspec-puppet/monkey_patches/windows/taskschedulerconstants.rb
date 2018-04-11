module RSpec
  module Puppet
    module Windows
      module TaskSchedulerConstants
	SYSTEM_USERS = ['NT AUTHORITY\SYSTEM', "SYSTEM", 'NT AUTHORITY\LOCALSERVICE', 'NT AUTHORITY\NETWORKSERVICE', 'BUILTIN\USERS', "USERS"].freeze

	# Triggers

	# Trigger is set to run the task a single time
	TASK_TIME_TRIGGER_ONCE = 1

	# Trigger is set to run the task on a daily interval
	TASK_TIME_TRIGGER_DAILY = 2

	# Trigger is set to run the task on specific days of a specific week & month
	TASK_TIME_TRIGGER_WEEKLY = 3

	# Trigger is set to run the task on specific day(s) of the month
	TASK_TIME_TRIGGER_MONTHLYDATE = 4

	# Trigger is set to run the task on specific day(s) of the month
	TASK_TIME_TRIGGER_MONTHLYDOW = 5

	# Trigger is set to run the task if the system remains idle for the amount
	# of time specified by the idle wait time of the task
	TASK_EVENT_TRIGGER_ON_IDLE = 6

	TASK_TRIGGER_REGISTRATION = 7

	# Trigger is set to run the task at system startup
	TASK_EVENT_TRIGGER_AT_SYSTEMSTART = 8

	# Trigger is set to run the task when a user logs on
	TASK_EVENT_TRIGGER_AT_LOGON = 9

	TASK_TRIGGER_SESSION_STATE_CHANGE = 11

	# Daily Tasks

	# The task will run on Sunday
	TASK_SUNDAY = 0x1

	# The task will run on Monday
	TASK_MONDAY = 0x2

	# The task will run on Tuesday
	TASK_TUESDAY = 0x4

	# The task will run on Wednesday
	TASK_WEDNESDAY = 0x8

	# The task will run on Thursday
	TASK_THURSDAY = 0x10

	# The task will run on Friday
	TASK_FRIDAY = 0x20

	# The task will run on Saturday
	TASK_SATURDAY = 0x40

	# Weekly tasks

	# The task will run between the 1st and 7th day of the month
	TASK_FIRST_WEEK = 0x01

	# The task will run between the 8th and 14th day of the month
	TASK_SECOND_WEEK = 0x02

	# The task will run between the 15th and 21st day of the month
	TASK_THIRD_WEEK = 0x04

	# The task will run between the 22nd and 28th day of the month
	TASK_FOURTH_WEEK = 0x08

	# The task will run the last seven days of the month
	TASK_LAST_WEEK = 0x10

	# Monthly tasks

	# The task will run in January
	TASK_JANUARY = 0x1

	# The task will run in February
	TASK_FEBRUARY = 0x2

	# The task will run in March
	TASK_MARCH = 0x4

	# The task will run in April
	TASK_APRIL = 0x8

	# The task will run in May
	TASK_MAY = 0x10

	# The task will run in June
	TASK_JUNE = 0x20

	# The task will run in July
	TASK_JULY = 0x40

	# The task will run in August
	TASK_AUGUST = 0x80

	# The task will run in September
	TASK_SEPTEMBER = 0x100

	# The task will run in October
	TASK_OCTOBER = 0x200

	# The task will run in November
	TASK_NOVEMBER = 0x400

	# The task will run in December
	TASK_DECEMBER = 0x800

	# Flags

	# Used when converting AT service jobs into work items
	TASK_FLAG_INTERACTIVE = 0x1

	# The work item will be deleted when there are no more scheduled run times
	TASK_FLAG_DELETE_WHEN_DONE = 0x2

	# The work item is disabled. Useful for temporarily disabling a task
	TASK_FLAG_DISABLED = 0x4

	# The work item begins only if the computer is not in use at the scheduled
	# start time
	TASK_FLAG_START_ONLY_IF_IDLE = 0x10

	# The work item terminates if the computer makes an idle to non-idle
	# transition while the work item is running
	TASK_FLAG_KILL_ON_IDLE_END = 0x20

	# The work item does not start if the computer is running on battery power
	TASK_FLAG_DONT_START_IF_ON_BATTERIES = 0x40

	# The work item ends, and the associated application quits, if the computer
	# switches to battery power
	TASK_FLAG_KILL_IF_GOING_ON_BATTERIES = 0x80

	# The work item starts only if the computer is in a docking station
	TASK_FLAG_RUN_ONLY_IF_DOCKED = 0x100

	# The work item created will be hidden
	TASK_FLAG_HIDDEN = 0x200

	# The work item runs only if there is a valid internet connection
	TASK_FLAG_RUN_IF_CONNECTED_TO_INTERNET = 0x400

	# The work item starts again if the computer makes a non-idle to idle
	# transition
	TASK_FLAG_RESTART_ON_IDLE_RESUME = 0x800

	# The work item causes the system to be resumed, or awakened, if the
	# system is running on batter power
	TASK_FLAG_SYSTEM_REQUIRED = 0x1000

	# The work item runs only if a specified account is logged on interactively
	TASK_FLAG_RUN_ONLY_IF_LOGGED_ON = 0x2000

	# Triggers

	# The task will stop at some point in time
	TASK_TRIGGER_FLAG_HAS_END_DATE = 0x1

	# The task can be stopped at the end of the repetition period
	TASK_TRIGGER_FLAG_KILL_AT_DURATION_END = 0x2

	# The task trigger is disabled
	TASK_TRIGGER_FLAG_DISABLED = 0x4

	# Run Level Types
	# Tasks will be run with the least privileges
	TASK_RUNLEVEL_LUA      = 0
	# Tasks will be run with the highest privileges
	TASK_RUNLEVEL_HIGHEST  = 1

	# Logon Types
	# Used for non-NT credentials
	TASK_LOGON_NONE                           = 0
	# Use a password for logging on the user
	TASK_LOGON_PASSWORD                       = 1
	# The service will log the user on using Service For User
	TASK_LOGON_S4U                            = 2
	# Task will be run only in an existing interactive session
	TASK_LOGON_INTERACTIVE_TOKEN              = 3
	# Group activation. The groupId field specifies the group
	TASK_LOGON_GROUP                          = 4
	# When Local System, Local Service, or Network Service account is
	# being used as a security context to run the task
	TASK_LOGON_SERVICE_ACCOUNT                = 5
	# Not in use; currently identical to TASK_LOGON_PASSWORD
	TASK_LOGON_INTERACTIVE_TOKEN_OR_PASSWORD  = 6


	TASK_MAX_RUN_TIMES = 1440
	TASKS_TO_RETRIEVE  = 5

	# Task creation

	TASK_VALIDATE_ONLY = 0x1
	TASK_CREATE = 0x2
	TASK_UPDATE = 0x4
	TASK_CREATE_OR_UPDATE = 0x6
	TASK_DISABLE = 0x8
	TASK_DONT_ADD_PRINCIPAL_ACE = 0x10
	TASK_IGNORE_REGISTRATION_TRIGGERS = 0x20

	# Priority classes

	REALTIME_PRIORITY_CLASS     = 0
	HIGH_PRIORITY_CLASS         = 1
	ABOVE_NORMAL_PRIORITY_CLASS = 2 # Or 3
	NORMAL_PRIORITY_CLASS       = 4 # Or 5, 6
	BELOW_NORMAL_PRIORITY_CLASS = 7 # Or 8
	IDLE_PRIORITY_CLASS         = 9 # Or 10

	CLSCTX_INPROC_SERVER  = 0x1
	CLSID_CTask =  [0x148BD520,0xA2AB,0x11CE,0xB1,0x1F,0x00,0xAA,0x00,0x53,0x05,0x03].pack('LSSC8')
	CLSID_CTaskScheduler =  [0x148BD52A,0xA2AB,0x11CE,0xB1,0x1F,0x00,0xAA,0x00,0x53,0x05,0x03].pack('LSSC8')
	IID_ITaskScheduler = [0x148BD527,0xA2AB,0x11CE,0xB1,0x1F,0x00,0xAA,0x00,0x53,0x05,0x03].pack('LSSC8')
	IID_ITask = [0x148BD524,0xA2AB,0x11CE,0xB1,0x1F,0x00,0xAA,0x00,0x53,0x05,0x03].pack('LSSC8')
	IID_IPersistFile = [0x0000010b,0x0000,0x0000,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46].pack('LSSC8')

	# Days of month

	TASK_FIRST = 0x01
	TASK_SECOND = 0x02
	TASK_THIRD = 0x04
	TASK_FOURTH = 0x08
	TASK_FIFTH = 0x10
	TASK_SIXTH = 0x20
	TASK_SEVENTH = 0x40
	TASK_EIGHTH = 0x80
	TASK_NINETH = 0x100
	TASK_TENTH = 0x200
	TASK_ELEVENTH = 0x400
	TASK_TWELFTH = 0x800
	TASK_THIRTEENTH = 0x1000
	TASK_FOURTEENTH = 0x2000
	TASK_FIFTEENTH = 0x4000
	TASK_SIXTEENTH = 0x8000
	TASK_SEVENTEENTH = 0x10000
	TASK_EIGHTEENTH = 0x20000
	TASK_NINETEENTH = 0x40000
	TASK_TWENTIETH = 0x80000
	TASK_TWENTY_FIRST = 0x100000
	TASK_TWENTY_SECOND = 0x200000
	TASK_TWENTY_THIRD = 0x400000
	TASK_TWENTY_FOURTH = 0x800000
	TASK_TWENTY_FIFTH = 0x1000000
	TASK_TWENTY_SIXTH = 0x2000000
	TASK_TWENTY_SEVENTH = 0x4000000
	TASK_TWENTY_EIGHTH = 0x8000000
	TASK_TWENTY_NINTH = 0x10000000
	TASK_THIRTYETH = 0x20000000
	TASK_THIRTY_FIRST = 0x40000000
	TASK_LAST = 0x80000000
      end
    end
  end
end

begin
  require 'win32/windows/constants'
rescue LoadError
  module Windows
    TaskSchedulerConstants = RSpec::Puppet::Windows::TaskSchedulerConstants
  end
end
