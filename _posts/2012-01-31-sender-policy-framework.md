---
title: Sender Policy Framework (SPF) for email SPAM Reduction
tags: [spf,email,spam,javamail,smtp,dns]
---
Since I can tell that I don't fully understand this myself, I'll start by pointing to these articles which more fully & authoritatively describe SPF's purpose, behavior, and effects:

*   [Sender Policy Framework Introduction](http://www.openspf.net/Introduction)
*   [Sender Policy Framework at Wikipedia](http://en.wikipedia.org/wiki/Sender_Policy_Framework)

### Sender Addresses

The first concept to understand is that SMTP email contains an "envelope" with an "**envelope sender address**" (sometimes called the "**return-path**" and technically the SMTP **MAIL FROM** command)  that is separate from the "From" header in the message itself (a.k.a. the "**header sender address**").

The **envelope sender address** is what actually receives bounces, BTW. It's sent, and potentially checked, before the email message itself (including the header) is even delivered. The **header sender address** is what a user's email client typically displays, and it obviously doesn't always match the domain of the SMTP server which actually originated the message.

### Sender Policy Framework

SPF, then, is an attempt to prevent forging of the **envelope sender**, not the **header sender**.

SPF is a combination of "sender" and "receiver" actions. The domain owner publishes a special kind of DNS record indicating which servers are authorized to send emails from its users. The receivers then verify that the IP address from which the email originated is in that authorized list for the domain.

So the purpose of SPF isn't to allow _anotherdomain.com_ servers to send email on behalf of _somedomain.com_, the original requirement I was investigating; that can be done without SPF. Its purpose is the opposite: to tell receivers (who check) not to accept email which claims to come from _somedomain.com_ (that is, with an **envelope sender address** of _somedomain.com_) unless the actual originating server's IP address is one listed as authorized to do so.

The primary goal seems to be reducing the amount of SPAM claiming to originate at _somedomain.com_.

#### Sender Addresses in JavaMail

Note that [JavaMail by default uses the **header sender** ("From" address) also as the **envelope sender address**](https://javamail.java.net/nonav/docs/api/com/sun/mail/smtp/package-summary.html), but this doesn't have to be the case.

### Potential Problems with SPF

The main potential problem I see is that [email forwarding services typically don't work with SPF](http://en.wikipedia.org/wiki/Sender_Policy_Framework#FAIL_and_forwarding). That is, if a domain publishes a restrictive SPF record, an individual receiving emails from that sender provides an email address that is actually a forwarding address, and the eventual destination of that forwarding address checks SPF records, the email will be rejected.

Since the sending server typically cannot control what kind of email addresses its customers provide, this seems like an unacceptable situation to me. Undoubtedly some end-users will provide email addresses which will be unable to receive email from a domain with strict SPF settings, and they'd never know they had done so. (Although the sending server should receive bounce emails indicating SPF failure in those cases.)

### SPF Implementation

_For those curious but not curious enough to work through the linked articles._

SPF is implemented by a domain adding a special kind of DNS record to its DNS server. (Apparently this can be either a TXT record or a SPF record, with the same content/format either way.) I won't go into [the details documented elsewhere](http://www.openspf.net/SPF_Record_Syntax), but a simple example would be:

```
somedomain.com. IN TXT "v=spf1 a mx -all"
```

Meaning, for email with an **envelope sender address** in _somedomain.com_, only accept the email if the sending IP is either one of the domain's DNS "A" servers (the main DNS record for a domain) or one of its DNS "MX" (mail) servers. Consider "all" other IP addresses a "hard FAIL" (i.e. reject them if you care about such things).

### Real Examples

I [looked up ibm.com](http://dnsquery.org/dnsquery/ibm.com/TXT) and saw that it actually has an SPF record that says no servers at all should be sending email for @ibm.com:

```
ibm.com. IN TXT "v=spf1 -all"
```

I had to ponder for a bit before I thought to [check us.ibm.com](http://dnsquery.org/dnsquery/us.ibm.com/TXT). It has several valid senders listed, including some IP ranges:

```
us.ibm.com. IN TXT "v=spf1 ip4:32.97.182.0/24 ip4:32.97.110.0/24 a:d25xlcore010.ca.ibm.com a:isource.boulder.ibm.com a:y01exnat001.ahe.pok.ibm.com a:y01acxsmtp001.ahe.pok.ibm.com a:y01acxsmtp002.ahe.pok.ibm.com a:g01zcdsmtp002.ahe.pok.ibm.com ~all"
```

#### Hard and Soft Fail

Note the difference in the "all" clauses in the previous two examples. "-all" (hyphen) means to treat emails from all (other) senders as a "hard FAIL". "~all" (tilde) means to treat them as a "SOFTFAIL". Note that [Google.com's SPF record](http://dnsquery.org/dnsquery/google.com/TXT) and [Microsoft.com's SPF record](http://dnsquery.org/dnsquery/microsoft.com/TXT) also use the SOFTFAIL default.

SOFTFAIL is theoretically intended as a transitional setting while you're testing out the implications of your SPF record/policy, with the recommendation that recipients accept the email but "mark" them in some way. But based on the noted use of that SOFTFAIL indicator by those large, savvy domains, I'd say that Hard FAILS probably reject too many real-world uses today. (I suspect the forwarding scenario described above as one of the main such problematic uses.)

### Updates

* _Dec 17 2014_ Interesting, just noticed today that microsoft.com now has a "hard fail" default on its SPF record. Wonder what that signifies in terms of current SPF support/practices... (google.com and ibm.com are still SOFTFAIL)
* _Apr 22 2016_ Just checked and noticed today that ibm.com now has `v=spf1 mx include:zuora.com -all`
