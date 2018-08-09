require 'spec_helper'

describe JSONAPI::Parser, '.parse_response!' do
  it 'succeeds on nil data' do
    payload = { 'data' => nil }

    expect { JSONAPI.parse_response!(payload) }.not_to raise_error
  end

  it 'succeeds on empty array data' do
    payload = { 'data' => [] }

    expect { JSONAPI.parse_response!(payload) }.not_to raise_error
  end

  it 'works' do
    payload = {
      'data' => [
        {
          'type' => 'articles',
          'id' => '1',
          'attributes' => { 'title' => 'JSON API paints my bikeshed!' },
          'links' => { 'self' => 'http://example.com/articles/1' },
          'relationships' => {
            'author' => {
              'links' => {
                'self' => 'http://example.com/articles/1/relationships/author',
                'related' => 'http://example.com/articles/1/author'
              },
              'data' => { 'type' => 'people', 'id' => '9' }
            },
            'journal' => {
              'data' => nil
            },
            'comments' => {
              'links' => {
                'self' => 'http://example.com/articles/1/relationships/comments',
                'related' => 'http://example.com/articles/1/comments'
              },
              'data' => [
                { 'type' => 'comments', 'id' => '5' },
                { 'type' => 'comments', 'id' => '12' }
              ]
            }
          }
        }
      ],
      'meta' => { 'count' => '13' }
    }

    expect { JSONAPI.parse_response!(payload) }.not_to raise_error
  end

  it 'passes regardless of id/type order' do
    payload = {
      'data' => [
        {
          'type' => 'articles',
          'id' => '1',
          'relationships' => {
            'comments' => {
              'data' => [
                { 'type' => 'comments', 'id' => '5' },
                { 'id' => '12', 'type' => 'comments' }
              ]
            }
          }
        }
      ]
    }

    expect { JSONAPI.parse_response!(payload) }.to_not raise_error
  end

  it 'fails when a top-level data array resource object is missing id' do
    payload = {
      'data' => [
        {
          'type' => 'articles',
          'attributes' => {'title' => 'JSON API paints my bikeshed!'}
        }
      ]
    }

    expect { JSONAPI.parse_response!(payload) }.to raise_error(
      JSONAPI::Parser::InvalidDocument,
      'A resource object must have an id.'
    )
  end

  it 'fails when a relationship object is missing id' do
    payload = {
      'data' => [
        {
          'type' => 'articles',
          'id' => '1',
          'relationships' => {
            'author' => {
              'data' => { 'type' => 'people' }
            }
          }
        }
      ]
    }

    expect { JSONAPI.parse_response!(payload) }.to raise_error(
      JSONAPI::Parser::InvalidDocument,
      'A resource identifier object MUST contain ["id", "type"] members.'
    )
  end

  it 'fails when the top-level resource object has no type' do
    payload = {
      'data' => {
        'id' => '1'
      }
    }

    expect { JSONAPI.parse_response!(payload) }.to raise_error(
      JSONAPI::Parser::InvalidDocument,
      'A resource object must have a type.'
    )
  end

  it 'passes when the top-level resource object has no id' do
    payload = {
      'data' => {
        'type' => 'articles',
        'attributes' => {'title' => 'JSON API paints my bikeshed!'}
      }
    }

    expect { JSONAPI.parse_response!(payload) }.to_not raise_error
  end
end
