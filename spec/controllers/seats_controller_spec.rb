require 'rails_helper'

RSpec.describe SeatsController, type: :controller do
  let!(:seat) { create(:seat) }

  describe 'GET index' do
    it 'assigns @seats' do
      get :index
      expect(assigns(:seats)).to eq([seat])
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET show' do
    it 'assigns the requested seat to @seat' do
      get :show, params: { id: seat.id }
      expect(assigns(:seat)).to eq(seat)
    end

    it 'renders the show template' do
      get :show, params: { id: seat.id }
      expect(response).to render_template('show')
    end
  end

  describe 'GET new' do
    it 'assigns a new seat to @seat' do
      get :new
      expect(assigns(:seat)).to be_a_new(Seat)
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'POST create' do
    context 'with valid attributes' do
      it 'creates a new seat' do
        expect {
          post :create, params: { seat: attributes_for(:seat) }
        }.to change(Seat, :count).by(1)
      end

      it 'redirects to the new seat' do
        post :create, params: { seat: attributes_for(:seat) }
        expect(response).to redirect_to(Seat.last)
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new seat' do
        expect {
          post :create, params: { seat: attributes_for(:seat, category: nil) }
        }.not_to change(Seat, :count)
      end

      it 'renders the new template' do
        post :create, params: { seat: attributes_for(:seat, category: nil) }
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PATCH update' do
    context 'with valid attributes' do
      it 'updates the seat' do
        patch :update, params: { id: seat.id, seat: { category: 'Updated Category' } }
        seat.reload
        expect(seat.category).to eq('Updated Category')
      end

      it 'redirects back to the event' do
        patch :update, params: { id: seat.id, seat: { category: 'Updated Category' } }
        expect(response).to redirect_to(seat)
      end
    end

    context 'with invalid attributes' do
      it 'does not update the seat' do
        patch :update, params: { id: seat.id, seat: { category: nil } }
        seat.reload
        expect(seat.category).not_to be_nil
      end

      it 'redirects back to the event' do
        patch :update, params: { id: seat.id, seat: { category: nil } }
        expect(response).to redirect_to(seat)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'deletes the seat' do
      expect {
        delete :destroy, params: { id: seat.id }
      }.to change(Seat, :count).
    end
end
end
end