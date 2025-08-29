# Notion Ruby Renderer

Notion 블록을 커스터마이징 가능한 스타일링과 이미지 처리를 통해 시맨틱 HTML로 렌더링하는 Ruby gem입니다.

## 설치

Gemfile에 다음 라인을 추가하세요:

```ruby
gem 'notion-ruby-renderer', path: '../notion-ruby-renderer'
```

그런 다음 실행:

    $ bundle install

## 사용법

### 기본 사용법

```ruby
require 'notion_ruby_renderer'

# 기본 설정으로 렌더러 생성
renderer = NotionRubyRenderer::Renderer.new

# Notion 블록을 HTML로 렌더링
html = renderer.render(notion_blocks_json)
```

### 커스텀 이미지 처리

```ruby
# 커스텀 이미지 핸들러 정의
image_handler = NotionRubyRenderer::CallbackImageHandler.new do |url, context|
  # 커스텀 이미지 처리 로직을 여기에 작성
  # 예를 들어, 이미지를 다운로드하고 로컬에 저장
  processed_url = download_and_store(url)
  processed_url
end

renderer = NotionRubyRenderer::Renderer.new(image_handler: image_handler)
```

### CSS 커스터마이징

다양한 요소들에 대한 CSS 클래스를 커스터마이징할 수 있습니다:

```ruby
renderer = NotionRubyRenderer::Renderer.new(
  css_classes: {
    paragraph: 'my-paragraph',
    h1: 'my-heading-1',
    h2: 'my-heading-2',
    blockquote: 'my-quote',
    code: 'my-code-block'
  }
)
```

### 기본 스타일 포함하기

```ruby
# 기본 CSS를 문자열로 가져오기
css = NotionRubyRenderer::CssProvider.default_css

# 인라인 스타일 태그 생성
style_tag = NotionRubyRenderer::CssProvider.css_tag(inline: true)

# 링크 태그 생성
link_tag = NotionRubyRenderer::CssProvider.css_tag(href: '/assets/notion.css')
```

## 지원되는 Notion 블록 타입

- 문단 (Paragraph)
- 제목 (H1, H2, H3)
- 글머리 기호 및 번호 매기기 목록
- 인용 블록
- 구문 강조를 지원하는 코드 블록
- 구분선
- 캡션이 있는 이미지
- 북마크
- 토글/상세 블록
- 콜아웃
- 표

## 개발

저장소를 체크아웃한 후, `bin/setup`을 실행하여 의존성을 설치하세요.

### 테스트 실행

```bash
# 모든 테스트 실행
bundle exec rspec

# 특정 테스트 파일 실행
bundle exec rspec spec/notion_ruby_renderer/renderer_spec.rb
```

### 시각적 프리뷰 생성

렌더링 결과를 시각적으로 확인할 수 있는 HTML 프리뷰를 생성할 수 있습니다:

```bash
# 프리뷰 HTML 생성
ruby spec/generate_preview.rb

# 생성된 파일은 spec/preview.html에 저장됩니다
# 브라우저에서 파일을 열어 렌더링 결과를 확인하세요
```

프리뷰 페이지는 다음 내용을 포함합니다:
- 지원되는 모든 Notion 블록 타입의 렌더링 예시
- 입력 블록 데이터 (JSON)
- 렌더링된 HTML 출력
- HTML 소스 코드

## 라이선스

이 gem은 MIT 라이선스 조건에 따라 오픈 소스로 제공됩니다.