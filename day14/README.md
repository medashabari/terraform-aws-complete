Before Terraform, you should understand this visually in the AWS Console GUI. Once you *see* it, Terraform becomes just automation.

Let’s simplify everything first — no Terraform, just concepts.

---

# 🎯 First: What Are You Actually Building?

You are building:

```
User → CloudFront → S3 Bucket
```

NOT:

```
User → S3 directly ❌
```

That’s the entire architecture.

Now let’s break down the confusing terms one by one.

---

# 1️⃣ ACL (Access Control List)

## 🧠 What it is (Simple Version)

An ACL is an **old way** of giving permissions directly on S3 objects or buckets.

Example:

* “Make this object public”
* “Let this AWS account read this object”

---

## 🚨 Why You’re Confused

Because ACLs are mostly **legacy** now.

Modern AWS best practice:

> ❌ Do NOT use ACLs
> ✅ Use IAM policies and bucket policies instead

That’s why you have this:

```hcl
aws_s3_bucket_public_access_block
```

This disables ACL-based public access.

### In GUI:

When creating a bucket:

* You’ll see “Block all public access” checkbox
* That disables public ACLs

You should always leave it ON.

---

# 2️⃣ OAI (Origin Access Identity) – OLD Way

Before 2022, CloudFront used something called **OAI**.

## What OAI Did

It created a special CloudFront identity that could access your private S3 bucket.

Architecture:

```
CloudFront (OAI user) → S3
```

But:

* It used older permission model
* Harder to manage
* Less flexible
* AWS now recommends NOT using it

So OAI = legacy method.

---

# 3️⃣ OAC (Origin Access Control) – NEW Way ✅

OAC replaces OAI.

Instead of creating a fake user, OAC:

* Uses SigV4 signed requests
* Is more secure
* Is the modern AWS recommendation

Architecture with OAC:

```
CloudFront → (signed request) → S3
```

S3 checks:

* Is this request from CloudFront?
* Is it from the correct distribution?
* Is it signed?

If yes → allow.

This is what your Terraform is doing.

---

## 🎯 Think of It Like This

| Feature                       | OAI  | OAC   |
| ----------------------------- | ---- | ----- |
| Old or New?                   | Old  | New   |
| Uses IAM user style identity? | Yes  | No    |
| Uses request signing (SigV4)? | No   | Yes   |
| Recommended?                  | ❌ No | ✅ Yes |

So forget OAI unless you’re maintaining legacy systems.

---

# 4️⃣ Price Class (CloudFront)

This one is simple once you see it visually.

CloudFront has edge locations worldwide.

More locations = more expensive.

---

## Price Classes

| Price Class    | Coverage           | Cost           |
| -------------- | ------------------ | -------------- |
| PriceClass_100 | US + Europe        | Cheapest       |
| PriceClass_200 | US + Europe + Asia | Medium         |
| PriceClass_All | Worldwide          | Most expensive |

So:

```hcl
price_class = "PriceClass_100"
```

Means:

> Only use US and Europe edge locations.

If your users are mostly in US/EU → save money.

---

# 5️⃣ How This Looks in GUI (Step-by-Step)

Here’s what I recommend:

## Step 1 — Create S3 Bucket

In Console:

* Go to S3
* Create bucket
* Keep "Block all public access" ON
* Do NOT enable static website hosting

That’s it.

---

## Step 2 — Upload index.html

Upload manually in GUI.

---

## Step 3 — Try Accessing S3 URL

It will fail with:

```
AccessDenied
```

Good. That means bucket is private.

---

## Step 4 — Create CloudFront Distribution

When creating:

* Origin = your S3 bucket
* Origin access = choose:
  → “Origin access control settings (recommended)”
* Create new OAC

AWS will:

* Create OAC
* Suggest bucket policy automatically

Accept it.

---

Now test CloudFront URL.

It works.

Now the architecture makes sense.

---

# 🔥 Why You Don’t Use S3 Static Website Hosting

There are two S3 modes:

### Mode 1: Static Website Hosting (OLD STYLE)

```
User → S3 (public)
```

Problems:

* Bucket must be public
* No OAC
* Less secure
* No private origin

---

### Mode 2: Private S3 + CloudFront (Modern)

```
User → CloudFront → Private S3
```

More secure.
More scalable.
Industry standard.

You are building Mode 2.

---

# 🧠 Mental Model That Will Make Everything Click

Forget all AWS terminology.

Think like this:

* S3 = Storage room
* CloudFront = Security guard + global delivery truck
* OAC = Security badge that lets CloudFront enter storage room
* Bucket Policy = Rule saying “Only guard with this badge may enter”
* Price Class = How many delivery cities you pay for

That’s it.

---

# 🎯 Why Terraform After GUI?

Because:

GUI = learning
Terraform = production automation

Once you:

* Create S3 manually
* Create CloudFront manually
* See bucket policy auto-generated

Then your Terraform code will feel obvious.

---

You’re building a **private S3-backed static website served securely through CloudFront**. Let’s break this down from the absolute basics and explain *what each block does* and *why it’s needed*.

We’ll follow the real-world flow of a user visiting your site.

---

# 🌍 Big Picture Architecture

User → **CloudFront** → **Private S3 Bucket**

- Users never access S3 directly.
- S3 is private.
- CloudFront securely fetches content from S3 using **Origin Access Control (OAC)**.

This is the modern, recommended AWS architecture.

---

# 1️⃣ S3 Bucket Creation

```hcl
resource "aws_s3_bucket" "website" {
  bucket_prefix = var.bucket_prefix
}
```

### What this does
Creates an **Amazon S3 bucket** to store your static website files.

S3 = object storage (stores files like HTML, CSS, JS, images).

### Why it’s required
Your static website files must live somewhere. S3 is:
- Cheap
- Durable
- Highly available
- Perfect for static content

`bucket_prefix` lets Terraform generate a unique bucket name.

---

# 2️⃣ Block Public Access

```hcl
resource "aws_s3_bucket_public_access_block" "website" {
```

### What this does
Forces the S3 bucket to be **private**.

### Why this is important

Without this:
- Anyone could potentially access your files directly via S3 URL.
- You lose control.
- It becomes less secure.

You want:
```
User → CloudFront → S3
```

NOT:
```
User → S3 directly ❌
```

Each setting:

| Setting | Meaning |
|----------|----------|
| `block_public_acls` | Prevents public ACLs |
| `block_public_policy` | Prevents public bucket policies |
| `ignore_public_acls` | Ignores any public ACLs |
| `restrict_public_buckets` | Extra safety against public access |

This ensures your bucket is fully private.

---

# 3️⃣ Origin Access Control (OAC)

```hcl
resource "aws_cloudfront_origin_access_control" "oac"
```

### What this does
Allows **CloudFront** to securely access your private S3 bucket.

### Why it exists

S3 is private. So how can CloudFront read it?

OAC:
- Signs requests from CloudFront to S3 using **SigV4**
- Proves to S3 that the request is legitimate
- Prevents direct public access

This is the modern replacement for OAI (Origin Access Identity).

---

# 4️⃣ S3 Bucket Policy

```hcl
resource "aws_s3_bucket_policy" "website"
```

### What this does
Explicitly allows **CloudFront** to read objects from S3.

### Why this is required

Even though OAC exists, S3 still needs a policy saying:

> “I trust CloudFront distribution X to read my objects.”

Important part:

```hcl
Principal = {
  Service = "cloudfront.amazonaws.com"
}
```

Means:
Only CloudFront can access.

```hcl
Condition = {
  StringEquals = {
    "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
  }
}
```

This restricts access to:
ONLY your specific CloudFront distribution.

Without this policy:
CloudFront would get **403 Access Denied** from S3.

---

# 5️⃣ Upload Website Files

```hcl
resource "aws_s3_object" "website_files"
```

### What this does
Uploads everything inside `/www` to S3.

```
www/
  index.html
  style.css
  script.js
  images/
```

Terraform loops through all files using:

```hcl
fileset("${path.module}/www", "**/*")
```

### Why this is required

Your S3 bucket starts empty.

This block:
- Uploads files
- Sets correct content types (VERY important)
- Tracks file changes using `etag`

Without proper `content_type`, browsers may:
- Download HTML instead of rendering it
- Misinterpret JS or CSS

---

# 6️⃣ CloudFront Distribution

```hcl
resource "aws_cloudfront_distribution" "s3_distribution"
```

This is the most important piece.

## What CloudFront Is

CloudFront is a **CDN (Content Delivery Network)**.

It:
- Caches your website globally
- Makes it faster
- Adds HTTPS
- Protects S3

---

## 🔹 Origin Block

```hcl
origin {
  domain_name = aws_s3_bucket.website.bucket_regional_domain_name
```

This tells CloudFront:

> “My files live in this S3 bucket.”

And attaches:
```hcl
origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
```

So CloudFront can securely access S3.

---

## 🔹 Enabled + IPv6

```hcl
enabled         = true
is_ipv6_enabled = true
```

Turns distribution on and supports IPv6.

---

## 🔹 Default Root Object

```hcl
default_root_object = "index.html"
```

Without this:

Visiting:
```
https://example.cloudfront.net/
```

Would give:
```
AccessDenied
```

With this:
CloudFront automatically serves `index.html`.

---

## 🔹 Default Cache Behavior

This defines how users interact with CloudFront.

### Allowed Methods

```hcl
allowed_methods = ["GET", "HEAD"]
```

Because it's a static site.
No POST, PUT, DELETE needed.

---

### Cached Methods

Only cache GET and HEAD.

---

### Viewer Protocol Policy

```hcl
viewer_protocol_policy = "redirect-to-https"
```

If someone uses HTTP:

```
http://example.com
```

CloudFront redirects to:

```
https://example.com
```

This gives:
- Free HTTPS
- Secure site

---

### TTL Settings

| Setting | Meaning |
|----------|----------|
| `min_ttl` | Minimum cache time |
| `default_ttl` | Default cache time (1 hour) |
| `max_ttl` | Maximum cache time |

CloudFront caches content so it doesn't hit S3 every time.

---

## 🔹 Price Class

```hcl
price_class = "PriceClass_100"
```

Limits CDN to cheaper regions (US + Europe).

Saves money.

---

## 🔹 Restrictions

No geo restrictions here.

You could block countries if needed.

---

## 🔹 Viewer Certificate

```hcl
cloudfront_default_certificate = true
```

Uses AWS-provided HTTPS certificate:
```
*.cloudfront.net
```

If you want:
```
yourdomain.com
```

You’d need:
- ACM certificate
- Custom domain config

---

# 🔐 Why This Architecture Is Secure

1. S3 is completely private
2. Only CloudFront can access it
3. Users must use HTTPS
4. No direct S3 URLs work
5. CloudFront caches and protects origin

This is AWS best practice.

---

# 🚀 What Happens When Someone Visits Your Site

Step-by-step:

1. User enters CloudFront URL
2. CloudFront checks cache
3. If cached → return immediately
4. If not cached:
   - CloudFront signs request using OAC
   - Sends request to S3
5. S3 verifies:
   - Is request from correct CloudFront?
   - Is SourceArn correct?
6. S3 returns object
7. CloudFront caches it
8. User receives content

---

# 🧠 Why We Don't Use "S3 Static Website Hosting"

You might wonder:

> Why not enable S3 static website hosting?

Because:
- It requires public bucket access ❌
- Cannot use OAC
- Less secure
- No private origin

Modern best practice:
S3 (private) + CloudFront + OAC

---

# 🎯 Summary of Each Resource

| Resource | Purpose |
|----------|----------|
| `aws_s3_bucket` | Stores website files |
| `aws_s3_bucket_public_access_block` | Makes bucket private |
| `aws_cloudfront_origin_access_control` | Allows secure CloudFront access |
| `aws_s3_bucket_policy` | Grants CloudFront permission |
| `aws_s3_object` | Uploads files |
| `aws_cloudfront_distribution` | CDN, HTTPS, caching |

---