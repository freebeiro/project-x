# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Posts', type: :request do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:event) { create(:event, group:) } # Use association here
  let(:token) { JwtService.encode(user_id: user.id) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:nested_path) { "/groups/#{group.id}/events/#{event.id}/api/v1/posts" }

  # Helper to set up authorization for the user
  def setup_authorization
    create(:group_membership, group:, user:)
  end

  describe 'GET /index' do
    # Use descriptive names and let (not let!)
    let(:first_post) { create(:post, user:, group:, event:, content: 'First Post') }
    let(:second_post) { create(:post, user:, group:, event:, content: 'Second Post') }

    context 'when authorized' do
      before do
        setup_authorization
        # Create posts needed for this context
        first_post
        second_post
        get nested_path, headers: auth_headers
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct number of posts' do
        expect(response.parsed_body.size).to eq(2)
      end

      it 'returns only posts for the correct event' do
        expect(response.parsed_body.pluck('id')).to contain_exactly(first_post.id, second_post.id)
      end

      it 'includes image_urls key' do
         expect(response.parsed_body.first).to have_key('image_urls')
      end
    end

    context 'when not authorized' do
      before { get nested_path, headers: auth_headers } # No setup_authorization call

      it 'returns http forbidden' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /create' do
    let(:valid_post_params) { { post: { content: 'A new text post' } } }
    let(:invalid_post_params) { { post: { content: '' } } } # No content and no image

    context 'when authorized' do
      before { setup_authorization }

      context 'with valid text content' do
        it 'creates a new Post' do
          expect do
            post nested_path, params: valid_post_params, headers: auth_headers
          end.to change(Post, :count).by(1)
        end

        it 'returns http created' do
          post nested_path, params: valid_post_params, headers: auth_headers
          expect(response).to have_http_status(:created)
        end

        # Split multi-expectation test
        describe 'response data' do
           before { post nested_path, params: valid_post_params, headers: auth_headers }

           it 'includes the post content' do
             expect(response.parsed_body['content']).to eq('A new text post')
           end

           it 'includes the user id' do
             expect(response.parsed_body['user']['id']).to eq(user.id)
           end

           it 'includes image_urls key' do
             expect(response.parsed_body).to have_key('image_urls')
           end
        end
      end

      context 'with invalid params (no content or image)' do
         it 'does not create a new Post' do
          expect do
            post nested_path, params: invalid_post_params, headers: auth_headers
          end.not_to change(Post, :count)
         end

         it 'returns http unprocessable entity' do
           post nested_path, params: invalid_post_params, headers: auth_headers
           expect(response).to have_http_status(:unprocessable_entity)
         end
      end

      # Pending tests for image uploads
      pending 'handles image uploads correctly (requires fixture setup)'
    end

    context 'when not authorized' do
      it 'does not create a post' do
         expect do
            post nested_path, params: valid_post_params, headers: auth_headers
         end.not_to change(Post, :count)
      end

       it 'returns http forbidden' do
         post nested_path, params: valid_post_params, headers: auth_headers
         expect(response).to have_http_status(:forbidden)
       end
    end
  end
end
