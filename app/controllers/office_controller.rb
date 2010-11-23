class OfficeController < ApplicationController
  def update_vision
    Vision.create $xvars[:edit][:vision]
  end
  def create_student
    s= Student.new $xvars[:enter][:student]
    s.status= 1
    s.nursery_id= $xvars[:p][:id]
    s.save
    $xvars[:student_id]= s.id
    $xvars[:p][:return]= "/office/students/#{$xvars[:p][:id]}"
  end
  def students
    @nursery= Nursery.find params[:id]
  end
  def policies
    @nurseries= Nursery.all
  end
  def nurseries
    @nurseries= Nursery.all
  end
  def create_nursery
    Nursery.create $xvars[:enter][:nursery]
    gma_notice "ขึ้นทะเบียนเรียบร้อยแล้ว"
    $xvars[:p][:return]="/office/nurseries"
  end
  def update_nursery
    nursery= Nursery.find $xvars[:p][:id]
    nursery.update_attributes $xvars[:edit][:nursery]
    gma_notice "แก้ไขข้อมูลเรียบร้อยแล้ว"
    $xvars[:p][:return]= "/office/nurseries"
  end
  def rm_nursery
    nursery= Nursery.find $xvars[:p][:id]
    gma_notice "ลบข้อมูลเรียบร้อยแล้ว"
    nursery.destroy
    $xvars[:p][:return]= "/office/nurseries"
  end
  def senior_local
    @budget= 1
    @budget_title= "งบท้องถิ่น"
    @village_heads= VillageHead.all :order=>:moo
    render :layout => "print"
  end
  def senior_state
    @budget= 2
    @budget_title= "งบรัฐบาล"
    @village_heads= VillageHead.all :order=>:moo
    render :layout => "print", :template=>"office/senior_local"
  end
  def seniors
    @seniors= Senior.all :order=>'moo,fname'
  end
  def create_senior
    s= Senior.create $xvars[:enter][:senior]
    if s.id
      gma_notice "ขึ้นทะเบียนผู้ด้อยโอกาสเรียบร้อยแล้ว"
    else
      gma_notice s.errors[:nid]
    end
    $xvars[:senior_id]= s.id
    $xvars[:p][:return]= "/office/seniors"
  end
  def update_senior
    senior= Senior.find $xvars[:p][:id]
    senior.update_attributes $xvars[:edit][:senior]
    gma_notice "แก้ไขข้อมูล #{senior.full_name} เรียบร้อยแล้ว"
    $xvars[:p][:return]= "/office/seniors"
  end
  def rm_senior
    senior= Senior.find $xvars[:p][:id]
    gma_notice "ลบข้อมูล #{senior.full_name} เรียบร้อยแล้ว"
    senior.destroy
    $xvars[:p][:return]= "/office/seniors"
  end
  def village_heads
    @village_heads= VillageHead.all :order=>"moo"
  end
  def create_village_head
    VillageHead.create $xvars[:enter][:village_head]
    gma_notice "ขึ้นทะเบียนผู้ใหญ่บ้านเรียบร้อยแล้ว"
    $xvars[:p][:return]="/office/village_heads"
  end
  def update_village_head
    village_head= VillageHead.find $xvars[:p][:id]
    village_head.update_attributes $xvars[:edit][:village_head]
    gma_notice "แก้ไขข้อมูล #{village_head.full_name} เรียบร้อยแล้ว"
    $xvars[:p][:return]= "/office/village_heads"
  end
  def rm_village_head
    village_head= VillageHead.find $xvars[:p][:id]
    gma_notice "ลบข้อมูล #{village_head.full_name} เรียบร้อยแล้ว"
    village_head.destroy
    $xvars[:p][:return]= "/office/village_heads"
  end
  def cars
    @cars= Car.all :order=>'vtype,brand'
  end
  def create_car
    car = Car.new $xvars[:enter_car][:car]
    car.save
    gma_notice "เพิ่มรถส่วนกลางเรียบร้อยแล้ว"
    $xvars[:p][:return]="/office/cars"
  end
  def rm_car
    car= Car.find $xvars[:p][:id]
    gma_notice "ลบข้อมูลรถส่วนกลาง #{car.name} เรียบร้อยแล้ว"
    car.destroy
    $xvars[:p][:return]="/office/cars"
  end
  def create_doc_in
    doc= Doc.new $xvars[:register][:doc]
    doc.dtype= 1
    doc.save
    $xvars[:doc_id]= doc.id
    # $xvars[:action]= {:assign=>User.find_by_login('pornchai').id}
    set_songrit(:num_in, doc.rnum+1)
  end
  def create_doc_out
    doc= Doc.new $xvars[:register][:doc]
    doc.dtype= 2
    doc.save
    $xvars[:doc_id]= doc.id
    set_songrit(:num_out, doc.rnum+1)
  end
  def create_memo
    doc= Doc.new $xvars[:new][:doc]
    doc.dtype= 3
    doc.save
    $xvars[:doc_id]= doc.id
    $xvars[:action]= {:assign=>$xvars[:new][:assign]}
    u = User.find $user_id
    $xvars[:section_id] = u.section_id
  end
  def save_comment
    comment = Comment.create(:content=>$xvars[:action][:comment], :gma_xmain_id=>$xmain.id)
    comment.id
    unless $xvars[:section_id]
      if $xvars[:action][:assign]
        u = User.find $xvars[:action][:assign].to_i
        $xvars[:section_id]= u.section_id
      else
        # default to สำนักปลัด if not assign
        $xvars[:section_id]= 1
      end
    end
  end
  
  # ajax
  def car_schedule
    if params[:id]
      car= Car.find params[:id]
      t = []
      car.car_requests.active.each do |r|
        t << "#{date_thai r.schedule_at} #{r.name} (#{r.destination})"
      end
      render :text=> t.join('<br/>')
    else
      render :text=> ""
    end
  end
  def get_districts
    province= Province.find params[:id]
    prompt= "<option value="">..กรุณาเลือกอำเภอ</option>"
    render :text => prompt+@template.options_from_collection_for_select(province.districts,:id,:name)
  end
  def get_sub_districts
    district= District.find params[:id]
    render :text => @template.options_from_collection_for_select(district.sub_districts,:id,:name)
  end
  
  private
  def self.assigned?
    return $xvars[:action] ? $xvars[:action][:assign].to_i==$user.id : false
  end
end
