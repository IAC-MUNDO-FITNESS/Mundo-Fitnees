# ============================================
# Módulo CloudFront - El Mundo Fitness
# ============================================

# Origin Access Control (OAC) - Recomendado sobre OAI
resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC para acceso a S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Distribución de CloudFront
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Distribución CloudFront para ${var.project_name}"
  default_root_object = "index.html"
  price_class         = var.price_class
  web_acl_id          = var.web_acl_arn # Conexión con WAF

  # Origen S3
  origin {
    domain_name              = var.s3_bucket_domain_name
    origin_id                = "S3-${var.s3_bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  # Comportamiento de caché por defecto
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.s3_bucket_name}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  # Restricciones geográficas (opcional)
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Certificado SSL
  viewer_certificate {
    cloudfront_default_certificate = true
    # Para certificado personalizado:
    # acm_certificate_arn      = var.acm_certificate_arn
    # ssl_support_method       = "sni-only"
    # minimum_protocol_version = "TLSv1.2_2021"
  }

  # Página de error personalizada
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-cloudfront"
    }
  )
}

# Política del Bucket S3 para permitir acceso desde CloudFront
resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = var.s3_bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${var.s3_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main.arn
          }
        }
      }
    ]
  })
}
