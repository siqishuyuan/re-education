require 'spec_helper'

describe CommentsController do

  let!(:publisher) { FactoryGirl.create :publisher }
  let!(:current_user) { FactoryGirl.create :publisher }
  let!(:lessonplan) { FactoryGirl.create :lessonplan, publisher: publisher }

  before :each do
    controller.stub(:current_user).and_return(current_user)
  end

  describe '#index' do

    before {
      10.times do |i|
        FactoryGirl.create :comment, publisher: publisher, :commentable_type => 'Lessonplan', :commentable_id => lessonplan.id
      end

      get :index, lessonplan_id: lessonplan.id, format: :json
    }

    specify { JSON.parse(response.body).size.should == 10 }

  end

  describe '#create' do

    describe do

      before { post :create, lessonplan_id: lessonplan.id, comment: { content: 'test comment content' }, format: :json }

      specify { JSON.parse(response.body)['content'].should == 'test comment content' }

      specify { JSON.parse(response.body)['publisher']['id'].should == current_user.id }

    end

    context 'content is empty' do

      before { post :create, lessonplan_id: lessonplan.id, comment: {}, format: :json }

      specify { JSON.parse(response.body)['status'].should == 'empty' }

    end

    context 'content is duplicate' do

      let!(:comment) do 
        FactoryGirl.create :comment, publisher: current_user, commentable_type: 'Lessonplan', commentable_id: lessonplan.id
      end

      before do
        comment = FactoryGirl.create :comment, publisher: current_user, :commentable_type => 'Lessonplan', :commentable_id => lessonplan.id
        post :create, lessonplan_id: lessonplan.id, comment: { content: comment.content }, format: :json
      end

      specify { JSON.parse(response.body)['status'].should == 'duplicate' }

    end

  end


  describe "#destroy" do

    let!(:comment) do
      FactoryGirl.create :comment, publisher: current_user, commentable_type: 'Lessonplan', commentable_id: lessonplan.id
    end

    it "should destroy specify comment" do

      expect do
        delete :destroy, lessonplan_id: lessonplan.id, id: comment.id
      end.to change(Comment, :count).by(-1)

    end

  end

end
