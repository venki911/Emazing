require 'test_helper'

class GaExportsControllerTest < ActionController::TestCase
  setup do
    @ga_export = ga_exports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ga_exports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ga_export" do
    assert_difference('GaExport.count') do
      post :create, ga_export: { end_date: @ga_export.end_date, ga_data: @ga_export.ga_data, kind: @ga_export.kind, profile_id: @ga_export.profile_id, start_date: @ga_export.start_date }
    end

    assert_redirected_to ga_export_path(assigns(:ga_export))
  end

  test "should show ga_export" do
    get :show, id: @ga_export
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ga_export
    assert_response :success
  end

  test "should update ga_export" do
    patch :update, id: @ga_export, ga_export: { end_date: @ga_export.end_date, ga_data: @ga_export.ga_data, kind: @ga_export.kind, profile_id: @ga_export.profile_id, start_date: @ga_export.start_date }
    assert_redirected_to ga_export_path(assigns(:ga_export))
  end

  test "should destroy ga_export" do
    assert_difference('GaExport.count', -1) do
      delete :destroy, id: @ga_export
    end

    assert_redirected_to ga_exports_path
  end
end
