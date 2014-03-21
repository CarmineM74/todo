require 'spec_helper'

describe Api::V1::TasksController do
  default_version 1

  shared_examples "resource not found" do
    it "replies with resource not found" do
      expect(response.status).to eq(404)
    end

    it "returns not_found error" do
      expect(decoded_body.error).to eq('not_found')
    end
  end

  shared_examples "authentication required" do
    it "replies with status 401" do
      expect(response.status).to eq(401)
    end

    it "replies with authentication error" do
      expect(response).to be_api_error(RocketPants::Unauthenticated)
    end
  end

  shared_examples "paginated results" do
    it "returns pagination data" do
      expect(parsed_body).to have_key('pagination')
    end
  end

  let!(:user_attrs) { FactoryGirl.attributes_for(:user) }
  let!(:user) { FactoryGirl.create(:user, user_attrs) }
  let(:project_with_tasks) { FactoryGirl.create(:project_with_tasks, user: user) }
  let!(:first_task) { project_with_tasks.tasks.first }
  let(:project) { FactoryGirl.create(:project, user: user) }
  let(:another_project_with_tasks) { FactoryGirl.create(:project_with_tasks) }
  let(:task_attrs) { FactoryGirl.attributes_for(:task) }

  describe 'GET index', index: true do

    context 'when not logged in' do
      before(:each) do
        logout(user)
        get :index, project_id: project.id
      end

      it_behaves_like 'authentication required'
    end

    context 'when logged in' do
      before(:each) do
        login_as(user_attrs)
      end

      context 'and project belongs to current user' do
        context "when specified project does not exists" do
          before(:each) do
            project.id += 1974
            get :index, project_id: project.id
          end

          it_behaves_like "resource not found"
        end

      end

      context 'and project does not belongs to current user' do
        before(:each) do
          get :index, project_id: another_project_with_tasks.id
        end

        it_behaves_like 'resource not found'
      end

      context "when the specified project exist" do
        context "and has tasks" do
          before(:each) { get :index, project_id: project_with_tasks.id }

          it_behaves_like 'paginated results'

          it "returns the list of tasks for the project" do
            expect(response).to be_paginated_resource
          end

          it "has count GT 0" do
            expect(parsed_body['count']).not_to eq(0)
          end
        end

        context "and has no tasks" do
          before(:each) { get :index, project_id: project.id }

          it_behaves_like 'paginated results'

          it "response is empty" do
            puts parsed_body
            expect(decoded_body.response).to be_empty
          end

          it "has count EQ 0" do
            expect(parsed_body['count']).to eq(0)
          end
        end
      end
    end
  end

  describe 'GET show task', show: true do

    def do_verb(project_id, task_id)
      get :show, project_id: project_id, id: task_id
    end

    context 'when not logged in' do
      before(:each) do
        logout(user)
        get :show, project_id: project_with_tasks.id, id: 1
      end

      it_behaves_like 'authentication required'
    end

    context 'when logged in' do
      before(:each) { login_as(user_attrs) }

      context 'and the project exists' do
        context 'and the task does not exists' do
          before(:each) { do_verb(project_with_tasks.id,project_with_tasks.tasks.first.id+1980) }
          it_behaves_like 'resource not found'
        end

        context 'and the task exists' do
          before(:each) { do_verb(project_with_tasks.id,project_with_tasks.tasks.first.id) }

          it 'the request completes successfully' do
            expect(response).to be_successful
          end

          it 'return the requested task in response' do
            expect(response).to be_singular_resource
            expect(decoded_body.response.id).to eq(project_with_tasks.tasks.first.id)
          end
        end
      end

      context 'otherwise' do
        before(:each) { do_verb(another_project_with_tasks.id, another_project_with_tasks.tasks.first.id) }

        it_behaves_like 'resource not found'
      end
    end
  end

  describe 'POST create task', create: true do

    def do_verb(project, task)
      post :create, project_id: project.id, task: task
    end

    context 'when not logged in' do
      before(:each) do
        logout(user)
        do_verb(project_with_tasks,task_attrs)
      end

      it_behaves_like 'authentication required'
    end

    context 'when logged in' do
      before(:each) { login_as(user_attrs) }

      context 'and specified project does not exists' do
        before(:each) do
          project.id += 1974
          do_verb(project,task_attrs)
        end

        it_behaves_like "resource not found"
      end

      context 'and specified project exists' do
        before(:each) { do_verb(project_with_tasks, task_attrs) }

        it 'replies with success (200)' do
          expect(response).to be_successful
        end

        it 'returns the task created' do
          expect(decoded_body.response.name).to eq(task_attrs[:name])
          expect(decoded_body.response.id).to_not be_nil
        end

        it 'has no errors' do
          expect(decoded_body.error).to be_nil
        end
      end
    end

  end

  describe 'PUT update task', update: true do

    def do_verb(project, task_id, task_attrs)
      put :update, project_id: project.id, id: task_id, task: task_attrs
    end

    context 'when not logged in' do
      before(:each) do
        logout(user)
        do_verb(project_with_tasks,first_task.id,{name: 'updated'})
      end

      it_behaves_like 'authentication required'
    end

    context 'when logged in' do
      before(:each) { login_as(user_attrs) }

      context 'and the specified project does not exists' do
        before(:each) do
          project_with_tasks.id += 1974
          do_verb(project_with_tasks,first_task.id,{name: 'updated'})
        end

        it_behaves_like "resource not found"
      end

      context 'and the project exist' do
        context "and the task doesn't belong to the specified project" do
          before(:each) do
            first_task.id += 800
            do_verb(project_with_tasks,first_task.id,{name: first_task.name})
          end

          it_behaves_like "resource not found"
        end

        context "and the task belongs to the specified project" do
          before(:each) { do_verb(project_with_tasks,first_task.id,{name: 'updated'}) }

          it "replies with success once the task has been updated" do
            expect(response).to be_successful
          end

          it "replies with the updated task" do
            expect(response).to be_singular_resource
            expect(decoded_body.response.name).to eq('updated')
          end
        end
      end
    end
  end

  describe 'DELETE delete task', delete: true do

    def do_verb(project_id, task_id)
      delete :destroy, project_id: project_id, id: task_id
    end

    context 'when not logged in' do
      before(:each) do
        logout(user)
        do_verb(project_with_tasks,first_task.id)
      end

      it_behaves_like 'authentication required'
    end

    context 'when logged in' do
      before(:each) { login_as(user_attrs) }

      context 'and the project does not exists' do
        before(:each) { do_verb(project_with_tasks.id+1540, first_task.id) }
        it_behaves_like "resource not found"
      end

      context 'when the project exist' do
        context 'and the task does not exists' do
          before(:each) { do_verb(project_with_tasks.id, first_task.id+1540) }
          it_behaves_like "resource not found"
        end

        context 'and the task exist' do
          it 'the task is deleted successfully' do
            do_verb(project_with_tasks.id,first_task.id)
            expect(response).to be_successful
          end
        end
      end
    end
  end
end

