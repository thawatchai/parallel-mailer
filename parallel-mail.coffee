async         = require('async')
nodemailer    = require('nodemailer')
smtpTransport = require('nodemailer-smtp-transport')
fs            = require('fs')
readline      = require('readline')
events        = require('events')
lineReader    = require('line-reader')
ProgressBar   = require('progress')

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

# get argruments
# --------------------------------------------------------------------
argv = require('optimist')
  .usage('Usage: $0 -m [mail.txt] -f [from adress] -l [email-list.csv]')
  .demand(['l', 'f', 'm'])
  .argv

# set up email message
# --------------------------------------------------------------------
email = fs.readFileSync argv.m, 'utf8'

transport = nodemailer.createTransport smtpTransport
  host : 'localhost'
  port : if argv.test then 1025 else 25

emailLines = email.split('\n')
mailOpts =
  from                 : argv.f
  subject              : emailLines[0].trim()
  html                 : emailLines.slice(1, emailLines.length).join('\n')
  generateTextFromHTML : true

# send emails
# --------------------------------------------------------------------

addrList = []

async.series
  loading: (callback) ->
    console.log 'loading...'
    lineReader.eachLine argv.l, (line, last) ->
      addrList.push line.split(',')[1].trim()
      callback null if last

  sending: (callback) ->
    addrListLength = addrList.length
    i = 1
    async.whilst ->
        i <= addrListLength

      , (callback) ->
        mailOpts['to'] = addrList[i-1]
        console.log "#{ i }: #{ mailOpts['to'] }"
        transport.sendMail mailOpts, (err, info) ->
          console.log err.message if err?
          i++
          callback null

      , (err) ->
        console.log 'sent all mails at ' + (new Date())


# # send emails
# # --------------------------------------------------------------------
#
# addrList = []
#
# eventEmitter = new events.EventEmitter()
#
# eventEmitter.on 'addrListLoaded', ->
#   async.eachLimit addrList, 20, (addr, callback) ->
#     mailOpts['to'] = addr
#     transport.sendMail mailOpts, (err, res) ->
#       if err
#         console.log err.message
#       else
#         console.log addr
#       # transport.close() if addr == addrList[addrList.length-1]
#       if addr == addrList[addrList.length-1]
#         console.log 'sent all mails at ' + (new Date())
#         console.log "press Ctrl+C when you're sure that SMTP's picked up all mails."
#     setImmediate () ->
#       callback null
#   , (err) ->
#     console.log 'queued all'
#
#
# readline.createInterface
#     input: fs.createReadStream argv.l
#     terminal: false
#   .on 'line', (line) ->
#     addr = line.split(',')[1].trim()
#     addrList.push addr
#   .on 'close', ->
#     eventEmitter.emit 'addrListLoaded'
#
